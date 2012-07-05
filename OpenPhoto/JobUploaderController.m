//
//  JobUploaderController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 03/07/12.
//  Copyright 2012 OpenPhoto
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "JobUploaderController.h"

@interface JobUploaderController (){
    BOOL running;
}
- (void) executeJob;

@end

@implementation JobUploaderController


+ (JobUploaderController*) getController
{
    static dispatch_once_t pred;
    static JobUploaderController *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[JobUploaderController alloc] init];
    });
    
    return shared; 
}

- (void) start
{
    running = YES;
    
    dispatch_queue_t jobQueue = dispatch_queue_create("job_queue", NULL);
    dispatch_async(jobQueue, ^{
        @try {
            // start the thread
            while (running) {
                // sleep for 5 seconds
                [NSThread sleepForTimeInterval:5];
                // execute the method
                [self executeJob];
            }       
        }@catch (NSException *exception) {
            NSLog(@"Error in the job %@", [exception description]);
        }
    });
    dispatch_release(jobQueue);
}

- (void) stop
{
    // this will stop the thread
    running = NO;
}

- (BOOL) isRunning
{
    return running;
}


- (void) executeJob
{
    NSLog(@"Executing uploader job");
    
    // in the main thread 
    
    // check how many are in state UPLOADING
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        int i = [TimelinePhotos howEntitiesTimelinePhotosInManagedObjectContext:[AppDelegate managedObjectContext] type:kUploadStatusTypeUploading];
        int created = [TimelinePhotos howEntitiesTimelinePhotosInManagedObjectContext:[AppDelegate managedObjectContext] type:kUploadStatusTypeCreated];

        if ( created == 0 ){
            [TimelinePhotos deleteEntitiesInManagedObjectContext:[AppDelegate managedObjectContext] state:kUploadStatusTypeUploadFinished]; 
            [TimelinePhotos deleteEntitiesInManagedObjectContext:[AppDelegate managedObjectContext] state:kUploadStatusTypeDuplicated];   
        }
        
        // TODO: if they are older than 4 minutes, but then to RETRY
        if (i < 2 && created > 0){
            
            //  looks for uploads in the state WAITING
            NSArray *waitings = [TimelinePhotos getNextWaitingToUploadInManagedObjectContext:[AppDelegate managedObjectContext] qtd:2-i];  
            
            // loop in the list and start to upload
            for (TimelinePhotos *photo in waitings){
                photo.status = kUploadStatusTypeUploading;
                
                NSDictionary *dictionary = nil;
                @try {
                    dictionary = [photo toDictionary];
                }
                @catch (NSException *e) {
                    photo.status = kUploadStatusTypeFailed;
                    break;
                }
                
                // send
                dispatch_queue_t uploader = dispatch_queue_create("job_uploader", NULL);
                dispatch_async(uploader, ^{
                    
                    @try{
                        // prepare the data to upload
                        NSString *filename = photo.fileName;
                        NSData *data = photo.photoData;
                        
                        // create the service, check photo exists and send the request
                        OpenPhotoService *service = [OpenPhotoServiceFactory createOpenPhotoService];
                        
                        // before check if the photo already exist
                        if ([service isPhotoAlreadyOnServer:[SHA1 sha1File:data]]){
                            @throw  [NSException exceptionWithName: @"Failed to upload" reason:@"You already uploaded this photo." userInfo: nil];
                        }else{
                            NSDictionary *response = [service uploadPicture:data metadata:dictionary fileName:filename];
                            [service release];
#ifdef DEVELOPMENT_ENABLED                        
                            NSLog(@"Photo uploaded correctly");
#endif
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                photo.status = kUploadStatusTypeUploadFinished; 
                                photo.photoUploadResponse = [NSDictionarySerializer nsDictionaryToNSData:[response objectForKey:@"result"]];
#ifdef TEST_FLIGHT_ENABLED
                                [TestFlight passCheckpoint:@"Image uploaded"];
#endif
                                
                            });
                        }
                    }@catch (NSException* e) {
                        NSLog(@"Error %@",e);
                        
                        // if it fails for any reason, set status FAILED in the main thread
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // check if it is duplicated
                            if ([[e description] hasPrefix:@"Error: 409 - This photo already exists based on a"] ||
                                [[e description] hasPrefix:@"You already uploaded this photo."]){
                                photo.status = kUploadStatusTypeDuplicated;
                            }else {
                                photo.status = kUploadStatusTypeFailed;
                                NSLog(@"Error to upload %@", [e description]);
                            }
                        });
                    }
                });
                dispatch_release(uploader);
            }
        }
    });
}

@end
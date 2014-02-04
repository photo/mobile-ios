//
//  PhotoUploader.m
//  Trovebox
//
//  Created by Patrick Santana on 08/06/13.
//  Copyright 2013 Trovebox
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
//

#import "PhotoUploader.h"

@interface PhotoUploader()

- (void) saveEntityUploadDate:(NSDate *) date
                shareFacebook:(NSNumber *) facebook
                 shareTwitter:(NSNumber *) twitter
                        image:(NSData *) image
                   permission:(NSNumber *) permission
                         tags:(NSString *) tags
                       albums:(NSString *) albums
                        title:(NSString *) title
                          url:(NSURL *) url
                     groupUrl:(NSString *) urlGroup;

@end

@implementation PhotoUploader

@synthesize assetsLibrary=_assetsLibrary;

- (id)init
{
    self = [super init];
    if (self) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return self;
}

- (void) loadDataAndSaveEntityUploadDate:(NSDate *) date
                           shareFacebook:(NSNumber *) facebook
                            shareTwitter:(NSNumber *) twitter
                              permission:(NSNumber *) permission
                                    tags:(NSString *) tags
                                  albums:(NSString *) albums
                                   title:(NSString *) title
                                     url:(NSURL *) url
                                groupUrl:(NSString *) urlGroup
{
    // load image and then save it to database
    // via block
    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *asset)
    {
        
        ALAssetRepresentation *rep = [asset defaultRepresentation];
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"GOT ASSET, File size: %f", [rep size] / (1024.0f*1024.0f));
#endif
        uint8_t* buffer = malloc([rep size]);
        
        NSError* error = NULL;
        NSUInteger bytes = [rep getBytes:buffer fromOffset:0 length:[rep size] error:&error];
        NSData *data = nil;
        
        if (bytes == [rep size]){
#ifdef DEVELOPMENT_ENABLED
            NSLog(@"Asset %@ loaded from Asset Library OK", url);
#endif
            data = [NSData dataWithBytes:buffer length:bytes];
            [self saveEntityUploadDate:date
                         shareFacebook:facebook
                          shareTwitter:twitter
                                 image:data
                            permission:permission
                                  tags:tags
                                albums:albums
                                 title:title
                                   url:url
                              groupUrl:urlGroup];
        }else{
            NSLog(@"Error '%@' reading bytes from asset: '%@'", [error localizedDescription], url);
        }
        
        free(buffer);
    };
    
    // block for failed image
    ALAssetsLibraryAccessFailureBlock failureBlock  = ^(NSError *error)
    {
        NSLog(@"Error '%@' getting asset from library", [error localizedDescription]);
    };
    
    // schedules the asset read
    [self.assetsLibrary assetForURL:url resultBlock:resultBlock failureBlock:failureBlock];
}

- (void) saveEntityUploadDate:(NSDate *) date
                shareFacebook:(NSNumber *) facebook
                 shareTwitter:(NSNumber *) twitter
                        image:(NSData *) image
                   permission:(NSNumber *) permission
                         tags:(NSString *) tags
                       albums:(NSString *) albums
                        title:(NSString *) title
                          url:(NSURL *) url
                     groupUrl:(NSString *) urlGroup
{
    if ( image != nil){
        
        // generate a file name
        NSString *name = [AssetsLibraryUtilities getFileNameForImage:image url:url];
        
        // check title of photo
        if (title == nil){
            title = [[NSString alloc]initWithFormat:@"\t%@",[AssetsLibraryUtilities getPhotoTitleForImage:image url:url]];
        }
        
        // generate path of temporary file
        NSURL *pathTemporaryFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:name]];
        
        // save in a temporary folder
        BOOL result = [image writeToURL:pathTemporaryFile atomically:NO];
        
        // generate a thumb
        CGSize itemSize = CGSizeMake(70, 70);
        UIGraphicsBeginImageContext(itemSize);
        
        UIImage *imageTemp =  [UIImage imageWithData:image];
        [imageTemp drawInRect:CGRectMake(0, 0, 70, 70)];
        imageTemp = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData* data =[NSData dataWithData:UIImagePNGRepresentation (imageTemp)];
        
        
        //in the main queue, generate TimelinePhotos
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool{
                if (result){
                    // data to be saved in the database
                    Timeline *uploadInfo =  [NSEntityDescription insertNewObjectForEntityForName:@"Timeline"
                                                                          inManagedObjectContext:[SharedAppDelegate managedObjectContext]];
                    
                    // details form this upload
                    uploadInfo.date = date;
                    uploadInfo.dateUploaded = date;
                    uploadInfo.facebook = facebook;
                    uploadInfo.twitter = twitter;
                    uploadInfo.permission = permission;
                    uploadInfo.title =  title;
                    uploadInfo.tags=tags;
                    uploadInfo.albums=albums;
                    uploadInfo.status=kUploadStatusTypeCreated;
                    uploadInfo.photoDataTempUrl = [pathTemporaryFile absoluteString];
                    uploadInfo.photoDataThumb = data;
                    uploadInfo.fileName = name;
                    uploadInfo.userUrl = [SharedAppDelegate userHost];
                    uploadInfo.photoToUpload = [NSNumber numberWithBool:YES];
                    uploadInfo.photoUploadMultiplesUrl = urlGroup;
                    
                    if (url){
                        // add to the sync list, with that we don't need to show photos already uploaded.
                        uploadInfo.syncedUrl = [AssetsLibraryUtilities getAssetsUrlId:url];
                    }
                }}
        });
    }
}
@end

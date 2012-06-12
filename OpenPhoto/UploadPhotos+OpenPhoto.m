//
//  UploadPhotos+OpenPhoto.m
//  OpenPhoto
//
//  Created by Patrick Santana on 20/03/12.
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
//

#import "UploadPhotos+OpenPhoto.h"

@implementation UploadPhotos (OpenPhoto)

//
// Constast for Upload Status
//
NSString * const kUploadStatusTypeCreated = @"Created";
NSString * const kUploadStatusTypeFailed = @"Failed";
NSString * const kUploadStatusTypeUploaded = @"Uploaded";
NSString * const kUploadStatusTypeUploading = @"Uploading";

//
// Constansts for the Source
//
NSString * const kUploadSourceUIImagePickerControllerSourceTypePhotoLibrary=@"SourceTypePhotoLibrary";
NSString * const kUploadSourceUIImagePickerControllerSourceTypeCamera=@"SourceTypeCamera";
NSString * const kUploadSourceUIImagePickerControllerSourceTypeSavedPhotosAlbum=@"SourceTypeSavedPhotosAlbum";


+ (NSArray *) getUploadsInManagedObjectContext:(NSManagedObjectContext *) context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"UploadPhotos"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (error){
        NSLog(@"Error to get all uploads on managed object context = %@",[error localizedDescription]);
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (UploadPhotos *model in matches) {
        [result addObject:model];
    }
    
    // return an array of Uploads
    return [result autorelease]; 
}

+ (NSArray *) getUploadsNotUploadedInManagedObjectContext:(NSManagedObjectContext *)context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"UploadPhotos"];
    
    // status not Uploaded
    request.predicate= [NSPredicate predicateWithFormat:@"status != %@", kUploadStatusTypeUploaded];   
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (error){
        NSLog(@"Error to get all uploads on managed object context = %@",[error localizedDescription]);
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (UploadPhotos *model in matches) {
        [result addObject:model];
    }
    
    // return an array of Uploads
    return [result autorelease]; 
}

+ (void) deleteAllUploadsInManagedObjectContext:(NSManagedObjectContext *)context{
    NSFetchRequest *allUploads = [[NSFetchRequest alloc] init];
    [allUploads setEntity:[NSEntityDescription entityForName:@"UploadPhotos" inManagedObjectContext:context]];
    [allUploads setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *uploads = [context executeFetchRequest:allUploads error:&error];
    if (error){
        NSLog(@"Error getting Uploads to delete all from managed object context = %@",[error localizedDescription]);
    }
    
    for (NSManagedObject *upload in uploads) {
        [context deleteObject:upload];
    }
    NSError *saveError = nil;
    if (![context save:&saveError]){
        NSLog(@"Error delete all uploads from managed object context = %@",[saveError localizedDescription]);
    }   
    
    // now we can release the object
    [allUploads release];
}

+ (void) deleteUploadedInManagedObjectContext:(NSManagedObjectContext *)context{
    NSFetchRequest *onlyUploadedRequest = [[NSFetchRequest alloc] init];
    [onlyUploadedRequest setEntity:[NSEntityDescription entityForName:@"UploadPhotos" inManagedObjectContext:context]];
    // status Uploaded
    onlyUploadedRequest.predicate= [NSPredicate predicateWithFormat:@"status == %@", kUploadStatusTypeUploaded];   
    [onlyUploadedRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *uploads = [context executeFetchRequest:onlyUploadedRequest error:&error];
    if (error){
        NSLog(@"Error to get the uploads with status UPLOADED %@",[error localizedDescription]);
    }
    
    for (NSManagedObject *upload in uploads) {
        [context deleteObject:upload];
    }
    NSError *saveError = nil;
    if (![context save:&saveError]){
        NSLog(@"Error delete uploads with status UPLOADED from managed object context = %@",[saveError localizedDescription]);
    }   
    
    // now we can release the object
    [onlyUploadedRequest release];
}

+ (int) howManyUploadingInManagedObjectContext:(NSManagedObjectContext *)context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"UploadPhotos"];
    request.predicate= [NSPredicate predicateWithFormat:@"status == %@", kUploadStatusTypeUploading];  
    [request setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (error){
        NSLog(@"Error to get how many uploading = %@",[error localizedDescription]);
    }
    
    return [result count];
}

- (NSDictionary *) toDictionary
{
    if (self.image){
        NSArray *keys = [NSArray arrayWithObjects: @"date", @"facebook", @"permission", @"source", @"status", @"title", @"twitter", @"image", @"fileName",@"tags", nil];  
        NSArray *objects = [NSArray arrayWithObjects:self.date,self.facebook,self.permission,self.source,self.status,self.title,self.twitter,self.image,self.fileName,self.tags, nil];  
        
        return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    }
    
    return nil;
}

@end

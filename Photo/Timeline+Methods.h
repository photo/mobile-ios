//
//  Timeline+Photo.h
//  Photo
//
//  Created by Patrick Santana on 22/03/12.
//  Copyright 2012 Photo
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

#import "Timeline.h"
#import "SHA1.h"

// constant
extern NSString * const kUploadStatusTypeCreating; // this is used while we are creating all UPLOAD entries. After all of them are finish, we changed to CREATED
extern NSString * const kUploadStatusTypeCreated;
extern NSString * const kUploadStatusTypeFailed;
extern NSString * const kUploadStatusTypeDuplicated;
extern NSString * const kUploadStatusTypeUploading;
extern NSString * const kUploadStatusTypeUploadFinished;

// images already in the server
extern NSString * const kUploadStatusTypeUploaded;

@interface Timeline (Methods)


+ (NSArray *) getNewestPhotosInManagedObjectContext:(NSManagedObjectContext *)context;
+ (void) insertIntoCoreData:(NSArray *) rawNewestPhotos InManagedObjectContext:(NSManagedObjectContext *)context;

// From upload
+ (NSArray *) getUploadsInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *) getUploadsNotUploadedInManagedObjectContext:(NSManagedObjectContext *)context;
+ (void) deleteAllTimelineInManagedObjectContext:(NSManagedObjectContext *)context;

+ (int) howEntitiesTimelineInManagedObjectContext:(NSManagedObjectContext *)context type:(NSString*) type;
+ (NSArray *) getNextWaitingToUploadInManagedObjectContext:(NSManagedObjectContext *)context qtd:(int) quantity;  
+ (void) deleteEntitiesInManagedObjectContext:(NSManagedObjectContext *)context state:(NSString*) state;  
+ (void) resetEntitiesOnStateUploadingInManagedObjectContext:(NSManagedObjectContext *)context;

+ (void) setUploadsStatusToCreatedInManagedObjectContext:(NSManagedObjectContext *)context;
- (NSDictionary *) toDictionary;

@end

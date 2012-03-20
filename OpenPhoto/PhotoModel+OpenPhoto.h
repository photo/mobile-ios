//
//  PhotoModel+OpenPhoto.h
//  OpenPhoto
//
//  Created by Patrick Santana on 12/03/12.
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

#import "PhotoModel.h"
#import "PhotoSource.h"

@interface PhotoModel (OpenPhoto)

+ (PhotoModel *) photoWithOpenPhotoInfo:(NSDictionary *) openphotoInfo 
            inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSArray *) getPhotosInManagedObjectContext:(NSManagedObjectContext *)context;

+ (void) deleteAllPhotosInManagedObjectContext:(NSManagedObjectContext *)context;

// this method is used to set the photos inside the gallery. It returns an array of Photo object
+ (NSArray *) getPhotosFromOpenPhotoService:(NSArray *) openPhotoResult inManagedObjectContext:(NSManagedObjectContext *)context;

// convert the model photo object from core data to Photo object for Galerry
+ (Photo *) toPhoto:(PhotoModel *) model;
@end

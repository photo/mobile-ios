//
//  Photos+OpenPhoto.m
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


#import "Photos+OpenPhoto.h"

@implementation Photos (OpenPhoto)

+ (Photos *) photoWithOpenPhotoInfo:(NSDictionary *) openphotoInfo 
             inManagedObjectContext:(NSManagedObjectContext *)context{
    Photos *photo = nil;
    
    // bring by id
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photos"];
    request.predicate= [NSPredicate predicateWithFormat:@"id=%@",[openphotoInfo objectForKey:@"id"]];   
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (error){
        NSLog(@"Error getting a photo on managed object context = %@",[error localizedDescription]);
    }
    
    
    // matches should never be null and also never more than 1
    if (!matches || [matches count] > 1){
        //TODO
    }else if ([matches count] == 0){
        // it is not inserted, so we create a new one
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:context];
        // set all details
        
        // needs to save
        if (![context save:&error]) {
            NSLog(@"Couldn't save Photo inside core data: %@", [error localizedDescription]);
        }
    }else{
        photo = [matches lastObject];
    }
    
    return photo;   
}

+ (NSArray *) getPhotosInManagedObjectContext:(NSManagedObjectContext *)context{
    // bring by id
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photos"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (error){
        NSLog(@"Error to get all photos on managed object context = %@",[error localizedDescription]);
    }
    // return photos on core data
    return matches; 
}

+ (void) deleteAllPhotosInManagedObjectContext:(NSManagedObjectContext *)context{
    NSFetchRequest *allPhotos = [[NSFetchRequest alloc] init];
    [allPhotos setEntity:[NSEntityDescription entityForName:@"Photos" inManagedObjectContext:context]];
    [allPhotos setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *photos = [context executeFetchRequest:allPhotos error:&error];
    if (error){
        NSLog(@"Error getting photos to delete all from managed object context = %@",[error localizedDescription]);
    }
    
    // now we can release the object
    [allPhotos release];
    
    for (NSManagedObject *photo in photos) {
        [context deleteObject:photo];
    }
    NSError *saveError = nil;
    if (![context save:&saveError]){
        NSLog(@"Error delete all photos from managed object context = %@",[error localizedDescription]);
    }   
}

+ (NSArray *) getPhotosFromOpenPhotoService:(NSArray *) openPhotoResult inManagedObjectContext:(NSManagedObjectContext *)context{
    return nil;
}

@end

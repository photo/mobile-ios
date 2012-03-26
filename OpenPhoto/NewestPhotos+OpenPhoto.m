//
//  NewestPhotos+OpenPhoto.m
//  OpenPhoto
//
//  Created by Patrick Santana on 22/03/12.
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

#import "NewestPhotos+OpenPhoto.h"

@implementation NewestPhotos (OpenPhoto)


+ (NSArray *) getNewestPhotosInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"NewestPhotos"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (error){
        NSLog(@"Error to get all newest photos on managed object context = %@",[error localizedDescription]);
    }
    
    return matches;
}


+ (void) deleteAllNewestPhotosInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"NewestPhotos" inManagedObjectContext:context]];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *photos = [context executeFetchRequest:fetchRequest error:&error];
    if (error){
        NSLog(@"Error getting newest photos to delete all from managed object context = %@",[error localizedDescription]);
    }
    
    // now we can release the object
    [fetchRequest release];
    
    for (NSManagedObject *photo in photos) {
        [context deleteObject:photo];
    }
    NSError *saveError = nil;
    if (![context save:&saveError]){
        NSLog(@"Error delete all newest photos from managed object context = %@",[error localizedDescription]);
    } 
}


@end

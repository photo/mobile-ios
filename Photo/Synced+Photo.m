//
//  Synced+Photo.m
//  Photo
//
//  Created by Patrick Santana on 21/05/12.
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

#import "Synced+Photo.h"

@implementation Synced (Photo)

//
// Constast for sync uploaded
//
NSString * const kSyncedStatusTypeUploaded = @"Uploaded";

+ (NSMutableArray *) getPathsInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSMutableArray *array = [NSMutableArray array];
    
    // get all syncs and put in the dictionary 
    // with all paths
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Synced"];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (error){
        NSLog(@"Error to get all paths from Synced on managed object context = %@",[error localizedDescription]);
        return nil;
    }
    
    for (Synced *model in matches) {
        [array addObject:model.filePath];
    }
    
    return array;
}

+ (void) deleteAllSyncedPhotosInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Synced" inManagedObjectContext:context]];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *photos = [context executeFetchRequest:fetchRequest error:&error];
    if (error){
        NSLog(@"Error getting timeline to delete all from managed object context = %@",[error localizedDescription]);
    }
    
    for (NSManagedObject *photo in photos) {
        [context deleteObject:photo];
    }
    
    NSError *saveError = nil;
    if (![context save:&saveError]){
        NSLog(@"Error delete all photos from managed object context = %@",[error localizedDescription]);
    }   
    
    // now we can release the object
    [fetchRequest release];  
}

@end

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
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
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
       
    for (NSManagedObject *photo in photos) {
        [context deleteObject:photo];
    }
    NSError *saveError = nil;
    if (![context save:&saveError]){
        NSLog(@"Error delete all newest photos from managed object context = %@",[error localizedDescription]);
    }
    
    // now we can release the object
    [fetchRequest release];
}

+ (void) insertIntoCoreData:(NSArray *) rawNewestPhotos InManagedObjectContext:(NSManagedObjectContext *)context{
    if ([rawNewestPhotos count]>0){
        for (NSDictionary *raw in rawNewestPhotos){
            // check if object exists
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"NewestPhotos"];
            request.predicate= [NSPredicate predicateWithFormat:@"key==%@",[NSString stringWithFormat:@"%@",[raw objectForKey:@"id"]]];   
            [request setIncludesPropertyValues:NO]; //only fetch the managedObjectID
            
            NSError *error = nil;
            NSArray *matches = [context executeFetchRequest:request error:&error];
            
            if (error){
                NSLog(@"Error getting a newest photo on managed object context = %@",[error localizedDescription]);
            }
            
            if (!matches || [matches count] > 0){
                NSLog(@"Object already exist");
            }else {
                NewestPhotos *newest = [NSEntityDescription insertNewObjectForEntityForName:@"NewestPhotos" 
                                                                     inManagedObjectContext:context];
                
                // get details URL
                if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
                    // retina display
                    newest.photoUrl =  [NSString stringWithFormat:@"%@",[raw objectForKey:@"path610x530xCR"]];
                }else{
                    // not retina display
                    newest.photoUrl =  [NSString stringWithFormat:@"%@",[raw objectForKey:@"path305x265xCR"]];
                }
                
                NSString *title = [raw objectForKey:@"title"];
                if ([title class] == [NSNull class] || [title isEqualToString:@""])
                    newest.title = [NSString stringWithFormat:@"%@",[raw objectForKey:@"filenameOriginal"]];
                else
                    newest.title = title;
                
                NSArray *tagsResult = [raw objectForKey:@"tags"];
                NSMutableString *tags = [NSMutableString string];
                if ([tagsResult class] != [NSNull class]) {
                    int i = 1;
                    for (NSString *tagDetails in tagsResult){
                        [tags appendString:[tagDetails stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                        if ( i < [tagsResult count])
                            [tags appendString:@", "];
                        
                        i++;
                    }}
                newest.tags=tags;
                
                newest.key=[NSString stringWithFormat:@"%@",[raw objectForKey:@"id"]];
                
                // get the date since 1970
                double d            = [[raw objectForKey:@"dateUploaded"] doubleValue];
                NSTimeInterval date =  d;
                newest.date          = [NSDate dateWithTimeIntervalSince1970:date];            
            }
        }
        
        // save context
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Couldn't save: %@", [error localizedDescription]);
        }
    }
}

@end

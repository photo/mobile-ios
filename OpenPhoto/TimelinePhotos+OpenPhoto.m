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

#import "TimelinePhotos+OpenPhoto.h"

@implementation TimelinePhotos (OpenPhoto)

//
// Constast for Upload Status
//
NSString * const kUploadStatusTypeCreated = @"Created";
NSString * const kUploadStatusTypeFailed = @"Failed";
NSString * const kUploadStatusTypeUploaded = @"Uploaded";
NSString * const kUploadStatusTypeUploading = @"Uploading";

+ (NSArray *) getUploadsInManagedObjectContext:(NSManagedObjectContext *) context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimelinePhotos"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (error){
        NSLog(@"Error to get all uploads on managed object context = %@",[error localizedDescription]);
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (TimelinePhotos *model in matches) {
        [result addObject:model];
    }
    
    // return an array of Uploads
    return [result autorelease]; 
}

+ (NSArray *) getUploadsNotUploadedInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimelinePhotos"];
    
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
    for (TimelinePhotos *model in matches) {
        [result addObject:model];
    }
    
    // return an array of Uploads
    return [result autorelease]; 
}


+ (int) howManyUploadingInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimelinePhotos"];
    request.predicate= [NSPredicate predicateWithFormat:@"status == %@", kUploadStatusTypeUploading];  
    [request setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (error){
        NSLog(@"Error to get how many uploading = %@",[error localizedDescription]);
    }
    
    return [result count];
}

+ (NSArray *) getNewestPhotosInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimelinePhotos"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateUploaded" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (error){
        NSLog(@"Error to get all newest photos on managed object context = %@",[error localizedDescription]);
    }
    
    return matches;
}


+ (void) deleteAllTimelineInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"TimelinePhotos" inManagedObjectContext:context]];
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
        NSLog(@"Error delete all newest photos from managed object context = %@",[saveError localizedDescription]);
    }
    
    // now we can release the object
    [fetchRequest release];
}

+ (void) insertIntoCoreData:(NSArray *) rawNewestPhotos InManagedObjectContext:(NSManagedObjectContext *)context
{
    if ([rawNewestPhotos count]>0){
        BOOL checkTotalRows = YES;
        for (NSDictionary *raw in rawNewestPhotos){
            // check if object exists
            if (checkTotalRows){
                if ([[raw objectForKey:@"totalRows"] intValue] == 0){
                    return;
                }else{
                    checkTotalRows  = NO;
                }
            }
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TimelinePhotos"];
            request.predicate= [NSPredicate predicateWithFormat:@"key==%@",[NSString stringWithFormat:@"%@",[raw objectForKey:@"id"]]];   
            [request setIncludesPropertyValues:NO]; //only fetch the managedObjectID
            
            NSError *error = nil;
            NSArray *matches = [context executeFetchRequest:request error:&error];
            
            if (error){
                NSLog(@"Error getting a newest photo on managed object context = %@",[error localizedDescription]);
            }
            
            if (!matches || [matches count] > 0){
#ifdef DEVELOPMENT_ENABLED              
                NSLog(@"Object already exist");
#endif
            }else {
                TimelinePhotos *newest = [NSEntityDescription insertNewObjectForEntityForName:@"TimelinePhotos" 
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
                
                // get the date taken since 1970
                double d            = [[raw objectForKey:@"dateTaken"] doubleValue];
                NSTimeInterval date =  d;
                newest.date          = [NSDate dateWithTimeIntervalSince1970:date];    
                
                // permission
                if ([[raw objectForKey:@"permission"] isEqualToString:@"1"])
                    newest.permission = [NSNumber numberWithBool:YES];
                else 
                    newest.permission = [NSNumber numberWithBool:NO];
                
                // latitude
                NSString *latitude = [raw objectForKey:@"latitude"];
                if ([latitude class] != [NSNull class] && ![latitude isEqualToString:@""])
                    newest.latitude = latitude;
                
                // longitude
                NSString *longitude = [raw objectForKey:@"longitude"];
                if ([longitude class] != [NSNull class] && ![longitude isEqualToString:@""])
                    newest.longitude = longitude;
                
                // get the date since 1970
                double dUpload            = [[raw objectForKey:@"dateUploaded"] doubleValue];
                NSTimeInterval dateUpload =  dUpload;
                newest.dateUploaded       = [NSDate dateWithTimeIntervalSince1970:dateUpload];  
                
                // page url
                newest.photoPageUrl =  [raw objectForKey:@"url"];
            }
        }
        
        // save context
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Couldn't save: %@", [error localizedDescription]);
        }
    }
}

- (NSDictionary *) toDictionary
{
    if (self.photoData){
        NSArray *keys = [NSArray arrayWithObjects: @"date", @"facebook", @"permission", @"status", @"title", @"twitter", @"image", @"fileName",@"tags", nil];  
        NSArray *objects = [NSArray arrayWithObjects:self.date,self.facebook,self.permission,self.status,self.title,self.twitter,self.photoData,self.fileName,self.tags, nil];  
        
        return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    }
    
    return nil;
}

@end

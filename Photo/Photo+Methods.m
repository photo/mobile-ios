//
//  Gallery+Photo.m
//  Trovebox
//
//  Created by Patrick Santana on 14/03/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "Photo+Methods.h"

@implementation Photo (Methods)

+ (Photo *) photoWithServerInfo:(NSDictionary *) response
                           inManagedObjectContext:(NSManagedObjectContext *) context
{
    Photo *photo = nil;
    
    if ([response objectForKey:@"id"] == nil){
        return photo;
    }
    
    // bring by id
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate= [NSPredicate predicateWithFormat:@"identification==%@",[NSString stringWithFormat:@"%@",[response objectForKey:@"id"]]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (error){
        NSLog(@"Error getting a photo on managed object context = %@",[error localizedDescription]);
    }
    
    // Get title of the image
    NSString *title = [response objectForKey:@"title"];
    if ([title class] == [NSNull class])
        title = @"";
    
    // small url and url
    NSString *thumbUrl  = [NSString stringWithFormat:@"%@", [response objectForKey:@"path200x200"]];
    NSString *url       = [NSString stringWithFormat:@"%@", [response objectForKey:@"path640x960"]];
    NSString *pageUrl   = [NSString stringWithFormat:@"%@", [response objectForKey:@"url"]];
    
    // matches should never be null and also never more than 1
    if (!matches || [matches count] > 1){
        NSLog(@"ATTENTION: Incorrect return data from the core data %@", matches);
    }else if ([matches count] == 0){
        // it is not inserted, so we create a new one
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        
        // set all details
        float width = [[response objectForKey:@"width"] floatValue];
        float height = [[response objectForKey:@"height"] floatValue];
        
        // get width and height for the thumb
        NSArray* thumbPhotoDetails = [response objectForKey:@"photo200x200"];
        float thumbWidth = [[thumbPhotoDetails objectAtIndex:1] floatValue];
        float thumbHeight = [[thumbPhotoDetails objectAtIndex:2] floatValue];
        
        // calculate the real size of the image. It will keep the aspect ratio.
        float realWidth = 0;
        float realHeight = 0;
        
        if(width/height >= 1) {
            // portrait or square
            realWidth = 640;
            realHeight = height/width*640;
        } else {
            // landscape
            realHeight = 960;
            realWidth = width/height*960;
        }
        
        photo.width          = [NSNumber numberWithFloat:realWidth];
        photo.height         = [NSNumber numberWithFloat:realHeight];
        photo.thumbUrl       = thumbUrl;
        photo.thumbHeight    = [NSNumber numberWithFloat:thumbHeight];
        photo.thumbWidth     = [NSNumber numberWithFloat:thumbWidth];
        photo.url            = url;
        photo.pageUrl        = pageUrl;
        photo.identification = [NSString stringWithFormat:@"%@",[response objectForKey:@"id"]];
        
        // get the date since 1970
        double d            = [[response objectForKey:@"dateTaken"] doubleValue];
        NSTimeInterval date =  d;
        photo.date          = [NSDate dateWithTimeIntervalSince1970:date];
        
        // needs to save
        if (![context save:&error]) {
            NSLog(@"Couldn't save Photo inside core data: %@", [error localizedDescription]);
        }
    }else{
        photo = [matches lastObject];
        
        if (![photo.thumbUrl isEqualToString:thumbUrl] || ![photo.url isEqualToString:url] || ![photo.title isEqualToString:title] || ![photo.pageUrl isEqualToString:pageUrl]  ){
#ifdef DEVELOPMENT_ENABLED
            NSLog(@" ==============  Object model photo was changed, update fields on database");
#endif
            photo.thumbUrl = thumbUrl;
            photo.url = url;
            photo.pageUrl = pageUrl;
            photo.title = title;
            
            if (![context save:&error]) {
                NSLog(@"Couldn't update Photo inside core data: %@", [error localizedDescription]);
            }
        }
    }
    
    return photo;
}

+ (NSArray *) getPhotosInManagedObjectContext:(NSManagedObjectContext *)context;
{
    // bring by id
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (error){
        NSLog(@"Error to get all photos on managed object context = %@",[error localizedDescription]);
    }
    
    return matches;
}

+ (void) deletePhotosInManagedObjectContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *allPhotos = [[NSFetchRequest alloc] init];
    [allPhotos setEntity:[NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context]];
    [allPhotos setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *photos = [context executeFetchRequest:allPhotos error:&error];
    if (error){
        NSLog(@"Error getting photos to delete all from managed object context = %@",[error localizedDescription]);
    }
    
    for (NSManagedObject *photo in photos) {
        [context deleteObject:photo];
    }
    NSError *saveError = nil;
    if (![context save:&saveError]){
        NSLog(@"Error delete all photos from managed object context = %@",[error localizedDescription]);
    }
}


@end

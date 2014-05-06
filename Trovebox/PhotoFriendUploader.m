//
//  PhotoFriendUploader.m
//  Trovebox
//
//  Created by Patrick Santana on 06/05/14.
//  Copyright (c) 2014 Trovebox. All rights reserved.
//

#import "PhotoFriendUploader.h"

@implementation PhotoFriendUploader


- (void) loadDataAndSaveEntityUrl:(NSString *) url
{
    //in the main queue, generate TimelinePhotos
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool{
            
            // data to be saved in the database
            Timeline *uploadInfo =  [NSEntityDescription insertNewObjectForEntityForName:@"Timeline"
                                                                  inManagedObjectContext:[SharedAppDelegate managedObjectContext]];
            
            // details form this upload
            uploadInfo.date = [NSDate date];
            uploadInfo.dateUploaded = [NSDate date];
            uploadInfo.facebook = [NSNumber numberWithBool:NO];
            uploadInfo.twitter = [NSNumber numberWithBool:NO];
            uploadInfo.permission = [NSNumber numberWithBool:NO];
            uploadInfo.title =  @"";
            uploadInfo.tags=@"";
            uploadInfo.albums=@"";
            uploadInfo.status=kUploadStatusTypeCreated;
            uploadInfo.userUrl = [SharedAppDelegate userHost];
            uploadInfo.photoToUpload = [NSNumber numberWithBool:YES];
            uploadInfo.photoUrl = url;
            uploadInfo.copyFromFriend = [NSNumber numberWithBool:YES];
            uploadInfo.photoDataTempUrl=@"";
            uploadInfo.fileName=@"";
        }
    });
}
@end

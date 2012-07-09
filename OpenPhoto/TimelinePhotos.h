//
//  TimelinePhotos.h
//  OpenPhoto
//
//  Created by Patrick Santana on 09/07/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TimelinePhotos : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * dateUploaded;
@property (nonatomic, retain) NSNumber * facebook;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSNumber * permission;
@property (nonatomic, retain) NSData * photoData;
@property (nonatomic, retain) NSString * photoPageUrl;
@property (nonatomic, retain) NSNumber * photoUploadProgress;
@property (nonatomic, retain) NSData * photoUploadResponse;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * syncedUrl;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * twitter;
@property (nonatomic, retain) NSString * userUrl;
@property (nonatomic, retain) NSNumber * photoToUpload;

@end

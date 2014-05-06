//
//  Timeline.h
//  Trovebox
//
//  Created by Patrick Santana on 06/05/14.
//  Copyright (c) 2014 Trovebox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Timeline : NSManagedObject

@property (nonatomic, retain) NSString * albums;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * dateUploaded;
@property (nonatomic, retain) NSNumber * facebook;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSNumber * permission;
@property (nonatomic, retain) NSString * photoDataTempUrl;
@property (nonatomic, retain) NSData * photoDataThumb;
@property (nonatomic, retain) NSString * photoPageUrl;
@property (nonatomic, retain) NSNumber * photoToUpload;
@property (nonatomic, retain) NSString * photoUploadMultiplesUrl;
@property (nonatomic, retain) NSNumber * photoUploadProgress;
@property (nonatomic, retain) NSData * photoUploadResponse;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSString * photoUrlDetail;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * syncedUrl;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * twitter;
@property (nonatomic, retain) NSString * userUrl;
@property (nonatomic, retain) NSNumber * copyFromFriend;

@end

//
//  NewestPhotos.h
//  OpenPhoto
//
//  Created by Patrick Santana on 15/06/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NewestPhotos : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * dateUploaded;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSNumber * permission;
@property (nonatomic, retain) NSData * photoData;
@property (nonatomic, retain) NSString * photoPageUrl;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * title;

@end

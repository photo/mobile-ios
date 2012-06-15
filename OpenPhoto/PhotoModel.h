//
//  PhotoModel.h
//  OpenPhoto
//
//  Created by Patrick Santana on 15/06/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PhotoModel : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * identification;
@property (nonatomic, retain) NSString * pageUrl;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * urlSmall;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSString * userUrl;

@end

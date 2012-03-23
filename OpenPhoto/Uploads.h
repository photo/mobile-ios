//
//  Uploads.h
//  OpenPhoto
//
//  Created by Patrick Santana on 23/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Uploads : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * facebook;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSNumber * permissionPrivate;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * twitter;

@end

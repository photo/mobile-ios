//
//  Photo.h
//  Trovebox
//
//  Created by Patrick Santana on 29/03/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * identification;
@property (nonatomic, retain) NSString * pageUrl;
@property (nonatomic, retain) NSNumber * thumbHeight;
@property (nonatomic, retain) NSString * thumbUrl;
@property (nonatomic, retain) NSNumber * thumbWidth;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * width;

@end

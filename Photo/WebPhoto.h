//
//  WebPhoto.h
//  Trovebox
//
//  Created by Patrick Santana on 19/03/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebPhoto : NSObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * identification;
@property (nonatomic, retain) NSString * pageUrl;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * thumbWidth;
@property (nonatomic, retain) NSNumber * thumbHeight;
@property (nonatomic, retain) NSString * thumbUrl;


+ (WebPhoto *) photoWithServerInfo:(NSDictionary *) response;

@end

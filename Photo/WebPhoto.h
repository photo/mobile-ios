//
//  WebPhoto.h
//  Trovebox
//
//  Created by Patrick Santana on 19/03/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWPhoto.h"

@interface WebPhoto : NSObject

@property (nonatomic, weak) NSDate * date;
@property (nonatomic, weak) NSNumber * height;
@property (nonatomic, weak) NSString * identification;
@property (nonatomic, weak) NSString * pageUrl;
@property (nonatomic, weak) NSString * title;
@property (nonatomic, weak) NSString * url;
@property (nonatomic, weak) NSNumber * width;
@property (nonatomic, weak) NSNumber * thumbWidth;
@property (nonatomic, weak) NSNumber * thumbHeight;
@property (nonatomic, weak) NSString * thumbUrl;
@property (nonatomic, weak) NSString * thumbUrl;
@property (nonatomic, weak) MWPhoto * mwphoto;


+ (WebPhoto *) photoWithServerInfo:(NSDictionary *) response;

@end

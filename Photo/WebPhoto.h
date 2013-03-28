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

@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSNumber * height;
@property (nonatomic, strong) NSString * identification;
@property (nonatomic, strong) NSString * pageUrl;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSNumber * width;
@property (nonatomic, strong) NSNumber * thumbWidth;
@property (nonatomic, strong) NSNumber * thumbHeight;
@property (nonatomic, strong) NSString * thumbUrl;
@property (nonatomic, strong) MWPhoto * mwphoto;


+ (WebPhoto *) photoWithServerInfo:(NSDictionary *) response;

@end

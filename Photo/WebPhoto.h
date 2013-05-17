//
//  WebPhoto.h
//  Trovebox
//
//  Created by Patrick Santana on 19/03/13.
//  Copyright 2013 Trovebox
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import "MWPhoto.h"

@interface WebPhoto : NSObject

@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSString * identification;
@property (nonatomic, strong) NSString * pageUrl;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSNumber * thumbWidth;
@property (nonatomic, strong) NSNumber * thumbHeight;
@property (nonatomic, strong) NSString * thumbUrl;
@property (nonatomic, strong) MWPhoto * mwphoto;

+ (WebPhoto *) photoWithServerInfo:(NSDictionary *) response;

@end

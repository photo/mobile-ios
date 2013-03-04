//
//  Timeline.h
//  Photo
//
//  Created by Patrick Santana on 15/10/12.
//  Copyright 2012 Photo
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
#import <CoreData/CoreData.h>


@interface Timeline : NSManagedObject

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
@property (nonatomic, retain) NSNumber * photoToUpload;
@property (nonatomic, retain) NSString * photoPageUrl;
@property (nonatomic, retain) NSString * photoUploadMultiplesUrl;
@property (nonatomic, retain) NSNumber * photoUploadProgress;
@property (nonatomic, retain) NSData * photoUploadResponse;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * syncedUrl;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * twitter;
@property (nonatomic, retain) NSString * userUrl;

@end

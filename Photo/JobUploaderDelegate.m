//
//  JobUploaderDelegate.m
//  OpenPhoto
//
//  Created by Patrick Santana on 05/07/12.
//  Copyright 2012 OpenPhoto
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

#import "JobUploaderDelegate.h"

@interface JobUploaderDelegate()
{
    BOOL needsUpdate;
}

@property (nonatomic, strong) NSNumber *alreadySent;
@property (nonatomic, strong) Timeline* photoDelegate;

@end


@implementation JobUploaderDelegate
@synthesize totalSize=_totalSize, alreadySent=_alreadySent, photoDelegate = _photoDelegate;

- (id) initWithPhoto:(Timeline *) photo size:(NSNumber *) bytes
{
    self = [super init];
    if (self) {
        self.photoDelegate = photo;
        self.totalSize = bytes;
        self.alreadySent = [NSNumber numberWithInt:0];
        needsUpdate = YES;
    }
    return self;
}

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    self.alreadySent = [NSNumber numberWithUnsignedLongLong:[self.alreadySent longLongValue] + bytes ];
    
    // update the object.
    // let's update the data only in 50% of the case. 
    // trying to avoid less updates on the database
    if (needsUpdate){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoDelegate.photoUploadProgress =[ NSNumber numberWithFloat:[self.alreadySent floatValue]/[self.totalSize floatValue]];
        });
        needsUpdate = NO;
    }else{
        needsUpdate = YES;
    }
    
}

@end

//
//  UpdateUtilities.h
//  OpenPhoto
//
//  Created by Patrick Santana on 31/10/11.
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

#import <UIKit/UIKit.h>
#import "AuthenticationHelper.h"
#import "WebService.h"
#import "AuthenticationHelper.h"

@interface UpdateUtilities : NSObject{
    WebService *service;
}
@property (nonatomic, retain) WebService *service;

// singleton
+(UpdateUtilities*) instance;

//methods
- (NSString*) getVersion;
- (BOOL) needsUpdate;
- (void) update;
- (void) updateSystemVersion;

@end

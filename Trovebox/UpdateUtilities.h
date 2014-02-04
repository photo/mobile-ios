//
//  UpdateUtilities.h
//  Trovebox
//
//  Created by Patrick Santana on 25/02/13.
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

#import <SDWebImage/SDImageCache.h>
#import "KeychainItemWrapper.h"

@interface UpdateUtilities : NSObject

// singleton
+(UpdateUtilities*) instance;

//methods
- (NSString*) getVersion;
- (BOOL) needsUpdate;
- (void) update;

// rename the server form OpenPhoto to Trovebox
- (void) fixOpenPhotoToTroveboxServer;

// this fix the problem with some servers being handle with upper case.
// There is some problems with token in this situation.
// So we just lower case the server url and it is solved.
- (void) fixServerLowerCase;

// check if user is still using the old version of saving password on the NSUserDefaults
// we should always use the keychain instead of properties
// and delete it from there
// for new users will be saved on Keychain
- (void) fixKeyChain;

@end

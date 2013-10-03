//
//  Constants.h
//  Trovebox
//
//  Created by Patrick Santana on 05/09/11.
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

@interface Constants : NSObject

extern NSString * const kAppInitialized;
extern NSString * const kPhotosArePrivate;
extern NSString * const kTroveboxServer;
extern NSString * const kTroveboxNameUser;
extern NSString * const kTroveboxEmailUser;

extern NSString * const kHomeScreenPictures;
extern NSString * const kHomeScreenPicturesTimestamp;
extern NSString * const kServerDetails;
extern NSString * const kServerDetailsIsHosted;

extern NSString * const kAuthenticationValid;

extern NSString * const kNotificationLoginAuthorize;
extern NSString * const kNotificationRefreshPictures;
extern NSString * const kNotificationCheckRefreshPictures;
extern NSString * const kNotificationShareInformationToFacebookOrTwitter;
extern NSString * const kNotificationNeededsUpdate;
extern NSString * const kNotificationNeededsUpdateHome;
extern NSString * const kNotificationDisableUpdateHome;
extern NSString * const kNotificationProfileRefresh;
extern NSString * const kNotificationProfileRemoveProgressBar;

extern NSString * const kCellIdentifierTitle;
extern NSString * const kCellIdentifierTags;
extern NSString * const kCellIdentifierAlbums;
extern NSString * const kCellIdentifierFilter;
extern NSString * const kCellIdentifierPrivate;
extern NSString * const kCellIdentifierShareFacebook;
extern NSString * const kCellIdentifierShareTwitter;

extern NSString * const kVersionApplicationInstalled;

extern NSString * const kValidateNotAllowedLocation;

extern NSString * const kSyncShowUploadedPhotos;

// For profile
extern NSString * const kProfileAccountType;
extern NSString * const kProfileLimitRemaining;
extern NSString * const kProfileAccountProReceipt;
extern NSString * const kProfileLatestUpdateDate;
extern NSString * const kProfileLimitAllowed;

// Auto Sync
extern NSString * const kAutoSyncEnabled;
extern NSString * const kAutoSyncMessageDisplayed;

// when defined, we will use Google Analytics
#define GOOGLE_ANALYTICS_ENABLED

// a lot of logs, don't use in production env.
#define DEVELOPMENT_ENABLED

// log the return information from the server
#define DEVELOPMENT_ENABLED_JSON_RETURN

// if set developer can have credentials printed in the console
#define DEVELOPMENT_CREDENTIALS_LOG_ENABLED

// to transform color from hex to RBG
//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@end
//
//  Constants.h
//  OpenPhoto
//
//  Created by Patrick Santana on 05/09/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

extern NSString * const kAppInitialized;
extern NSString * const kPhotosSaveCameraRollOrSnapshot;
extern NSString * const kPhotosSaveFiltered;
extern NSString * const kPhotosHighResolution;
extern NSString * const kPhotosArePrivate;
extern NSString * const kOpenPhotoServer;
extern NSString * const kHomeScreenPictures;
extern NSString * const kHomeScreenPicturesTimestamp;

extern NSString * const kAuthenticationValid;
extern NSString * const kAuthenticationOAuthToken;
extern NSString * const kAuthenticationOAuthSecret;
extern NSString * const kAuthenticationConsumerKey;
extern NSString * const kAuthenticationConsumerSecret;

extern NSString * const kNotificationLoginAuthorize;        
extern NSString * const kNotificationLoginNeeded;   
extern NSString * const kNotificationRefreshPictures;

extern int        const kNumbersRow;
extern NSString * const kCellIdentifierTitle;
extern NSString * const kCellIdentifierDescription;
extern NSString * const kCellIdentifierTags;
extern NSString * const kCellIdentifierFilter;
extern NSString * const kCellIdentifierPrivate;
extern NSString * const kCellIdentifierHighResolutionPicture;


// while using TestFlight, this variable will permit the app to save/send data
#define TEST_FLIGHT_ENABLED

@end
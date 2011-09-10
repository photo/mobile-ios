//
//  Constants.m
//  OpenPhoto
//
//  Created by Patrick Santana on 05/09/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

#import "Constants.h"

@implementation Constants


// Const for the app initialization variable
NSString * const kAppInitialized = @"app_initialized";
// Save original to Library - NSUserDefaults name
NSString * const kPhotosSaveCameraRollOrSnapshot=@"photos_save_camera_roll_or_snapshot";
// Save filtered to Library - NSUserDefaults name
NSString * const kPhotosSaveFiltered=@"photos_save_filtered";
// High resolution - NSUserDefaults name
NSString * const kPhotosHighResolution=@"photos_high_resolution";
// Privacy - NSUserDefaults name
NSString * const kPhotosArePrivate=@"photos_are_private";
// NSUserDefault variable name for the OpenPhoto Server
NSString * const kOpenPhotoServer=@"account_server";
// NSUserDefault variable to hold user pictures
NSString * const kHomeScreenPictures=@"home_pictures";
// NSUserDefault variable with information about the last time that the pictures were refreshed
NSString * const kHomeScreenPicturesTimestamp=@"home_pictures_timestamp";


/*
 * OAuth 1.0a
 * ===================================
 * There are 4 values for you to store: two tokens and two secrets
 * one for the "app" and another for the "user"
 * the two secrets are used to generate the signature but are not passed with the request
 * the two tokens are passed with the request
 */
NSString * const kAuthenticationValid=@"authentication_valid";
NSString * const kAuthenticationOAuthToken=@"authentication_oauth_token";
NSString * const kAuthenticationOAuthSecret=@"authentication_oauth_secret";
NSString * const kAuthenticationConsumerKey=@"authentication_consumer_key";
NSString * const kAuthenticationConsumerSecret=@"authentication_consumer_secret";


/*
 * Constants for Notification
 */
NSString * const kNotificationLoginAuthorize=@"notification_login_authorized";        
NSString * const kNotificationLoginNeeded=@"notification_login_needed";     
NSString * const kNotificationRefreshPictures=@"notification_refresh_pictures";  


/*
 * Constants for the table in the upload screen
 */
int        const kNumbersRow=6;
NSString * const kCellIdentifierTitle = @"cellIdentifierTitle";
NSString * const kCellIdentifierDescription = @"cellIdentifierDescription";
NSString * const kCellIdentifierTags=@"cellIdentifierTags";
NSString * const kCellIdentifierFilter=@"cellIdentifierFilter";
NSString * const kCellIdentifierPrivate=@"cellIdentifierPrivate";
NSString * const kCellIdentifierHighResolutionPicture=@"cellHighResolutionPicture";



@end

//
//  Constants.m
//  OpenPhoto
//
//  Created by Patrick Santana on 05/09/11.
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

#import "Constants.h"

@implementation Constants


// Const for the app initialization variable
NSString * const kAppInitialized = @"app_initialized";
// Save original to Library - NSUserDefaults name
NSString * const kPhotosSaveCameraRollOrSnapshot=@"photos_save_camera_roll_or_snapshot";
// Save filtered to Library - NSUserDefaults name
NSString * const kPhotosSaveFiltered=@"photos_save_filtered";
// Facebook - NSUserDefaults name
NSString * const kPhotosShareFacebook=@"photos_share_facebook";
// Twitter - NSUserDefaults name
NSString * const kPhotosShareTwitter=@"photos_share_twitter";
// Privacy - NSUserDefaults name
NSString * const kPhotosArePrivate=@"photos_are_private";
// NSUserDefault variable name for the OpenPhoto Server
NSString * const kOpenPhotoServer=@"account_server";
// NSUserDefault variable to hold user pictures
NSString * const kHomeScreenPictures=@"home_pictures";
// NSUserDefault variable with information about the last time that the pictures were refreshed
NSString * const kHomeScreenPicturesTimestamp=@"home_pictures_timestamp";
// NSUserDefault variable with information about the server
NSString * const kServerDetails=@"server_details";

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
NSString * const kNotificationCheckRefreshPictures=@"notification_check_refresh_pictures"; 
NSString * const kNotificationShareInformationToFacebookOrTwitter=@"notification_share_information_to_facebook_or_twitter";


/*
 * Constants for the table in the upload screen
 */
int        const kNumbersRow=6;
NSString * const kCellIdentifierTitle = @"cellIdentifierTitle";
NSString * const kCellIdentifierTags=@"cellIdentifierTags";
NSString * const kCellIdentifierFilter=@"cellIdentifierFilter";
NSString * const kCellIdentifierPrivate=@"cellIdentifierPrivate";
NSString * const kCellIdentifierShareFacebook=@"cellIdentifierShareToFacebook";
NSString * const kCellIdentifierShareTwitter=@"cellIdentifierShareToTwitter";


/*
 * Constants for the Updater
 */
NSString * const kVersionApplicationInstalled=@"version_application_installed";
 



@end

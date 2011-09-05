//
//  Constants.m
//  OpenPhoto
//
//  Created by Patrick Santana on 05/09/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

#import "Constants.h"

@implementation Constants


// Const for the server. In the future it will be inside the Settings
NSString * const kOpenPhotoServer = @"http://current.openphoto.me";
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

@end

//
//  UploadPhotosHelper.h
//  OpenPhoto
//
//  Created by Patrick Santana on 29/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadPhotosHelper : NSObject


// get the file name based on the dictionary created by the UploadPhotos+OpenPhoto
+ (NSString *) getFileNameForDictionary:(NSDictionary *) dictionary;
// get the file to upload based on the dictionary created by the UploadPhotos+OpenPhoto
+ (NSData *) getNSDataForDictionary:(NSDictionary *) dictionary;

@end

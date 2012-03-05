//
//  AssetsLibraryUtilities.h
//  OpenPhoto
//
//  Created by Patrick Santana on 04/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssetsLibraryUtilities : NSObject

+ (NSString*) getAssetsUrlExtension:(NSURL*) url;
+ (NSString*) getAssetsUrlId:(NSURL*) url;

@end

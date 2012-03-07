//
//  SHA1Utilite.h
//  OpenPhoto
//
//  Created by Patrick Santana on 06/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface SHA1 : NSObject

+ (NSString*) sha1:(NSString*) input;

@end

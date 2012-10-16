//
//  AccountOpenPhoto
//  OpenPhoto
//
//  Created by Patrick Santana on 06/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountOpenPhoto : NSObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *clientToken;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *userToken;
@property (nonatomic, strong) NSString *userSecret;


- (void) saveToStandardUserDefaults;

@end

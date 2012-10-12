//
//  AccountOpenPhoto
//  OpenPhoto
//
//  Created by Patrick Santana on 06/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountOpenPhoto : NSObject{
    NSString *email;
    NSString *host;
    NSString *clientToken;
    NSString *clientSecret;
    NSString *userToken;
    NSString *userSecret;
}

@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *host;
@property (nonatomic, retain) NSString *clientToken;
@property (nonatomic, retain) NSString *clientSecret;
@property (nonatomic, retain) NSString *userToken;
@property (nonatomic, retain) NSString *userSecret;


- (void) saveToStandardUserDefaults;

@end

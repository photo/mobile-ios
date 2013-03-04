//
//  Account
//  Trovebox
//
//  Created by Patrick Santana on 06/03/12.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "Account.h"


@implementation Account
@synthesize email=_email, host=_host, clientToken=_clientToken, clientSecret=_clientSecret, userToken=_userToken, userSecret=_userSecret;


- (void) saveToStandardUserDefaults{
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setValue:@"OK" forKey:kAuthenticationValid];
    [standardUserDefaults setValue:self.host forKey:kTroveboxServer];
    [standardUserDefaults setValue:self.email forKey:kTroveboxEmailUser];
    [standardUserDefaults setValue:self.userToken    forKey:kAuthenticationOAuthToken];
    [standardUserDefaults setValue:self.userSecret   forKey:kAuthenticationOAuthSecret];
    [standardUserDefaults setValue:self.clientToken  forKey:kAuthenticationConsumerKey];
    [standardUserDefaults setValue:self.clientSecret forKey:kAuthenticationConsumerSecret];
    [standardUserDefaults setValue:nil          forKey:kHomeScreenPicturesTimestamp];
    [standardUserDefaults setValue:nil          forKey:kHomeScreenPictures];
    
    // synchronize the keys
    [standardUserDefaults synchronize];  
}

@end

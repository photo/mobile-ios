//
//  AccountOpenPhoto
//  OpenPhoto
//
//  Created by Patrick Santana on 06/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "AccountOpenPhoto.h"


@implementation AccountOpenPhoto
@synthesize email=_email, host=_host, clientToken=_clientToken, clientSecret=_clientSecret, userToken=_userToken, userSecret=_userSecret;


- (void) saveToStandardUserDefaults{
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setValue:@"OK" forKey:kAuthenticationValid];
    [standardUserDefaults setValue:self.host forKey:kOpenPhotoServer];
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

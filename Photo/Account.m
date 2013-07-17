//
//  Account
//  Trovebox
//
//  Created by Patrick Santana on 06/03/12.
//  Copyright 2013 Trovebox
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
//

#import "Account.h"


@implementation Account
@synthesize email=_email, host=_host, clientToken=_clientToken, clientSecret=_clientSecret, userToken=_userToken, userSecret=_userSecret;


- (void) saveToStandardUserDefaults{
    // save information related to host and email
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setValue:@"OK"                forKey:kAuthenticationValid];
    [standardUserDefaults setValue:self.host            forKey:kTroveboxServer];
    [standardUserDefaults setValue:self.email           forKey:kTroveboxEmailUser];
    [standardUserDefaults setValue:nil                  forKey:kHomeScreenPicturesTimestamp];
    [standardUserDefaults setValue:nil                  forKey:kHomeScreenPictures];
    [standardUserDefaults setValue:[[UpdateUtilities instance] getVersion] forKey:kVersionApplicationInstalled];
    
    // synchronize the keys
    [standardUserDefaults synchronize];
    
    // save credentials
    // keychain for credentials
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithTrovebox];    
    [keychainItem setObject:self.userToken forKey:kAuthenticationOAuthToken];
    [keychainItem setObject:self.userSecret forKey:kAuthenticationOAuthSecret];
    [keychainItem setObject:self.clientToken forKey:kAuthenticationConsumerKey];
    [keychainItem setObject:self.clientSecret  forKey:kAuthenticationConsumerSecret];
}

@end

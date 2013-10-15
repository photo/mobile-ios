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
@synthesize profile=_profile, permission=_permission;

- (void) saveToStandardUserDefaults{
    // save information related to host and email
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setValue:@"OK"                forKey:kAuthenticationValid];
    [standardUserDefaults setValue:[self.host lowercaseString]            forKey:kTroveboxServer];
    [standardUserDefaults setValue:self.email           forKey:kTroveboxEmailUser];
    [standardUserDefaults setValue:nil                  forKey:kHomeScreenPicturesTimestamp];
    [standardUserDefaults setValue:nil                  forKey:kHomeScreenPictures];
    [standardUserDefaults setValue:[[UpdateUtilities instance] getVersion] forKey:kVersionApplicationInstalled];
    
    // synchronize the keys
    [standardUserDefaults synchronize];
    
    // save credentials
    // keychain for credentials
    KeychainItemWrapper *keychainItemOAuth = [[KeychainItemWrapper alloc]initWithTroveboxOAuth];
    KeychainItemWrapper *keychainItemConsumer = [[KeychainItemWrapper alloc]initWithTroveboxConsumer];
    
    [keychainItemOAuth setObject:self.userToken forKey:(__bridge id)(kSecAttrAccount)];
    [keychainItemOAuth setObject:self.userSecret forKey:(__bridge id)(kSecValueData)];
    [keychainItemConsumer setObject:self.clientToken forKey:(__bridge id)(kSecAttrAccount)];
    [keychainItemConsumer setObject:self.clientSecret  forKey:(__bridge id)(kSecValueData)];
}

@end

//
//  AccountOpenPhoto
//  Photo
//
//  Created by Patrick Santana on 06/03/12.
//  Copyright 2012 Photo
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

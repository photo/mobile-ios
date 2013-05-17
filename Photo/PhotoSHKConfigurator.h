//
//  PhotoSHKConfigurator.h
//  Trovebox
//
//  Created by Patrick Santana on 16/10/12.
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

#import "DefaultSHKConfigurator.h"
#import "SHKConfiguration.h"

@interface PhotoSHKConfigurator : DefaultSHKConfigurator

#define SHKMyAppName			@"App for OpenPhoto"
#define SHKMyAppURL				@"https://openphoto.me/for/iphone"

#define SHKFacebookUseSessionProxy  NO
#define SHKFacebookAppID      @""
#define SHKFacebookLocalAppID      @""
#define SHKFacebookSessionProxyURL  @""

#define SHKTwitterConsumerKey		@""
#define SHKTwitterSecret			@""
#define SHKTwitterCallbackUrl		@"http://openphoto.me" // You need to set this if using OAuth, see note above (xAuth users can skip it)
#define SHKTwitterUseXAuth			0 // To use xAuth, set to 1
#define SHKTwitterUsername			@"" // Enter your app's twitter account if you'd like to ask the user to follow it when logging in. (Only for xAuth)

// Bit.ly (for shortening URLs on Twitter) - http://bit.ly/account/register - after signup: http://bit.ly/a/your_api_key
#define SHKBitLyLogin				@""
#define SHKBitLyKey					@""

@end

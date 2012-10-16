//
//  PhotoSHKConfigurator.h
//  Photo
//
//  Created by Patrick Santana on 16/10/12.
//  Copyright (c) 2012 Photo Project. All rights reserved.
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

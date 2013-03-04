//
//  LoginViewController.h
//  Trovebox
//
//  Created by Patrick Santana on 02/05/12.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "LoginConnectViewController.h"
#import "LoginCreateAccountViewController.h"
#import "AuthenticationService.h"
#import "Account.h"
#import "MBProgressHUD.h"

#import "GAI.h"

@interface LoginViewController : GAITrackedViewController

- (IBAction)connectUsingFacebook:(id)sender;
- (IBAction)signUpWithEmail:(id)sender;
- (IBAction)signInWithEmail:(id)sender;

@end

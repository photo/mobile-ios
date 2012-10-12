//
//  LoginViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 02/05/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "LoginConnectViewController.h"
#import "LoginCreateAccountViewController.h"
#import "AccountLoginService.h"
#import "AccountOpenPhoto.h"
#import "MBProgressHUD.h"

@interface LoginViewController : UIViewController

- (IBAction)connectUsingFacebook:(id)sender;
- (IBAction)signUpWithEmail:(id)sender;
- (IBAction)signInWithEmail:(id)sender;

@end

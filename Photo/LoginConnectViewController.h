//
//  LoginConnectViewController.h
//  Trovebox
//
//  Created by Patrick Santana on 02/05/12.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "AuthenticationService.h"
#import "Account.h"
#import "MBProgressHUD.h"

#import "GAI.h"

@interface LoginConnectViewController : GAITrackedViewController<UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UITextField *email;
@property (retain, nonatomic) IBOutlet UITextField *password;

// actions
- (IBAction)login:(id)sender;
- (IBAction)recoverPassword:(id)sender;
- (IBAction)haveYourOwnInstance:(id)sender;
@end

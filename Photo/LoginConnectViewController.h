//
//  LoginConnectViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 02/05/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "AuthenticationService.h"
#import "AccountOpenPhoto.h"
#import "MBProgressHUD.h"

@interface LoginConnectViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *email;
@property (nonatomic, weak) IBOutlet UITextField *password;

// actions
- (IBAction)login:(id)sender;
- (IBAction)recoverPassword:(id)sender;
- (IBAction)haveYourOwnInstance:(id)sender;
@end

//
//  LoginCreateAccountViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 02/05/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "AuthenticationService.h"
#import "AccountOpenPhoto.h"
#import "MBProgressHUD.h"

@interface LoginCreateAccountViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *username;
@property (nonatomic, weak) IBOutlet UITextField *email;
@property (nonatomic, weak) IBOutlet UITextField *password;
@property (nonatomic, weak) IBOutlet UIButton *buttonCreateAccount;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundUsername;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundEmail;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundPassword;


// message for Create account with email
@property (nonatomic, weak) IBOutlet UILabel *createAccountLabelEnter;
@property (nonatomic, weak) IBOutlet UILabel *createAccountLabelYourUsername;
@property (nonatomic, weak) IBOutlet UILabel *createAccountLabelForYour;
@property (nonatomic, weak) IBOutlet UILabel *createAccountLabelOpenPhoto;


// message for create account with facebook
@property (nonatomic, weak) IBOutlet UILabel *facebookCreateAccountCreate;
@property (nonatomic, weak) IBOutlet UILabel *facebookCreateAccountUsername;
@property (nonatomic, weak) IBOutlet UILabel *facebookCreateAccountOpenPhoto;


- (IBAction)createAccount:(id)sender;
- (void) setFacebookCreateAccount;
@end

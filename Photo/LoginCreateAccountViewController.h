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

@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UIButton *buttonCreateAccount;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundUsername;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundEmail;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundPassword;


// message for Create account with email
@property (strong, nonatomic) IBOutlet UILabel *createAccountLabelEnter;
@property (strong, nonatomic) IBOutlet UILabel *createAccountLabelYourUsername;
@property (strong, nonatomic) IBOutlet UILabel *createAccountLabelForYour;
@property (strong, nonatomic) IBOutlet UILabel *createAccountLabelOpenPhoto;


// message for create account with facebook
@property (strong, nonatomic) IBOutlet UILabel *facebookCreateAccountCreate;
@property (strong, nonatomic) IBOutlet UILabel *facebookCreateAccountUsername;
@property (strong, nonatomic) IBOutlet UILabel *facebookCreateAccountOpenPhoto;


- (IBAction)createAccount:(id)sender;
- (void) setFacebookCreateAccount;
@end

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

@property (retain, nonatomic) IBOutlet UITextField *username;
@property (retain, nonatomic) IBOutlet UITextField *email;
@property (retain, nonatomic) IBOutlet UITextField *password;
@property (retain, nonatomic) IBOutlet UIButton *buttonCreateAccount;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundUsername;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundEmail;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundPassword;


// message for Create account with email
@property (retain, nonatomic) IBOutlet UILabel *createAccountLabelEnter;
@property (retain, nonatomic) IBOutlet UILabel *createAccountLabelYourUsername;
@property (retain, nonatomic) IBOutlet UILabel *createAccountLabelForYour;
@property (retain, nonatomic) IBOutlet UILabel *createAccountLabelOpenPhoto;


// message for create account with facebook
@property (retain, nonatomic) IBOutlet UILabel *facebookCreateAccountCreate;
@property (retain, nonatomic) IBOutlet UILabel *facebookCreateAccountUsername;
@property (retain, nonatomic) IBOutlet UILabel *facebookCreateAccountOpenPhoto;


- (IBAction)createAccount:(id)sender;
- (void) setFacebookCreateAccount;
@end

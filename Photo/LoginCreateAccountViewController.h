//
//  LoginCreateAccountViewController.h
//  Photo
//
//  Created by Patrick Santana on 02/05/12.
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

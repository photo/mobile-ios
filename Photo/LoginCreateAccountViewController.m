//
//  LoginCreateAccountViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 02/05/12.
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

#import "LoginCreateAccountViewController.h"

@interface LoginCreateAccountViewController ()

-(void) createAccountUsername:(NSString*) username withEmail:(NSString *) email andPassword:(NSString*) password;

// for creation account, there are too many fields, we need to put the view up. This is a control for that.
@property (nonatomic) BOOL isViewUp;
@end

@implementation LoginCreateAccountViewController

@synthesize username=_username;
@synthesize email=_email;
@synthesize password=_passoword;

@synthesize buttonCreateAccount;
@synthesize backgroundUsername;
@synthesize backgroundEmail;
@synthesize backgroundPassword;
@synthesize createAccountLabelEnter;
@synthesize createAccountLabelYourUsername;
@synthesize createAccountLabelForYour;
@synthesize createAccountLabelOpenPhoto;

@synthesize isViewUp = _isViewUp;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title=@"Create Account";
        self.isViewUp = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.trackedViewName = @"Create Account Screen";
    
    self.createAccountLabelEnter.hidden = NO;
    self.createAccountLabelYourUsername.hidden = NO;
    self.createAccountLabelForYour.hidden = NO;
    self.createAccountLabelOpenPhoto.hidden = NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    // if ipad, lets centralize fields
    if([DisplayUtilities isIPad]){
        self.email.center=self.backgroundEmail.center;
        self.password.center=self.backgroundPassword.center;
        self.username.center=self.backgroundUsername.center;
    }
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)createAccount:(id)sender
{
    
    if (![DisplayUtilities isIPad]){
        if ( self.isViewUp == YES){
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
                [self moveFieldsUpOrDown:+1];
            }completion:^(BOOL finished){
                self.isViewUp = NO;
            }];
        }}
    
    // no keyboard
    [self.username resignFirstResponder];
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    
    if ( [SharedAppDelegate internetActive] == NO ){
        // problem with internet, show message to user
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Please check your internet connection",@"")];
        [alert showAlert];
    }else{
        
        // user is creating account using email
        // check for email, username and password
        if (self.username.text == nil || [[self.username.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length ] == 0){
            //show message
            PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Please, set your username.",@"Creation account where user needs to set the username")];
            [alert showAlert];
            return;
        }
        
        if (self.email.text == nil || [[self.email.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length ] == 0){
            //show message
            PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Please, set your email.",@"Creation account where user needs to set the email")];
            [alert showAlert];
            return;
        }
        
        if (self.password.text == nil || [[self.password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length ] == 0){
            //show message
            PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Please, set your password",@"")];
            [alert showAlert];
            return;
        }
        
        // create account
        [self createAccountUsername:self.username.text withEmail:self.email.text andPassword:self.password.text];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (![DisplayUtilities isIPad]){
        
        if (self.isViewUp == NO){
            self.isViewUp = YES;
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
                [self moveFieldsUpOrDown:-1];
            }completion:^(BOOL finished){
            }];
        }}
}

// direction should be -1 for go up or +1 to go down.
-(void) moveFieldsUpOrDown:(int) direction
{
    
    if (direction != -1 && direction != +1){
        // we don't allow others values
        return;
    }
    
    // move up or down everything because we don't have space enough
    [self.createAccountLabelEnter setCenter:CGPointMake([self.createAccountLabelEnter  center].x, [self.createAccountLabelEnter center].y + (35 * direction))];
    [self.createAccountLabelYourUsername setCenter:CGPointMake([self.createAccountLabelYourUsername  center].x, [self.createAccountLabelYourUsername center].y + (35 * direction))];
    [self.createAccountLabelForYour setCenter:CGPointMake([self.createAccountLabelForYour  center].x, [self.createAccountLabelForYour center].y + (35 * direction))];
    [self.createAccountLabelOpenPhoto setCenter:CGPointMake([self.createAccountLabelOpenPhoto  center].x, [self.createAccountLabelOpenPhoto center].y + (35 * direction))];
    [self.username setCenter:CGPointMake([self.username  center].x, [self.username center].y + (35 * direction))];
    [self.email setCenter:CGPointMake([self.email  center].x, [self.email center].y + (35 * direction))];
    [self.password setCenter:CGPointMake([self.password  center].x, [self.password center].y + (35 * direction))];
    [self.buttonCreateAccount setCenter:CGPointMake([self.buttonCreateAccount  center].x, [self.buttonCreateAccount center].y + (35 * direction))];
    [self.backgroundUsername setCenter:CGPointMake([self.backgroundUsername  center].x, [self.backgroundUsername center].y + (35 * direction))];
    [self.backgroundEmail setCenter:CGPointMake([self.backgroundEmail  center].x, [self.backgroundEmail center].y + (35 * direction))];
    [self.backgroundPassword setCenter:CGPointMake([self.backgroundPassword  center].x, [self.backgroundPassword center].y + (35 * direction))];
    
}


// Action if user clicks in DONE in the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.username){
        [self.email becomeFirstResponder];
        return NO;
    }if (textField == self.email){
        [self.password becomeFirstResponder];
        return NO;
    }else{
        [textField resignFirstResponder];
        [self createAccount:nil];
        return YES;
    }
}

- (void)viewDidUnload
{
    
    [self setUsername:nil];
    [self setEmail:nil];
    [self setPassword:nil];
    [self setButtonCreateAccount:nil];
    [self setBackgroundUsername:nil];
    [self setBackgroundEmail:nil];
    [self setBackgroundPassword:nil];
    [self setCreateAccountLabelEnter:nil];
    [self setCreateAccountLabelYourUsername:nil];
    [self setCreateAccountLabelForYour:nil];
    [self setCreateAccountLabelOpenPhoto:nil];
    
    [super viewDidUnload];
}


////
//// Private methods
////
-(void) createAccountUsername:(NSString*) username withEmail:(NSString *) email andPassword:(NSString*) password
{
    // display
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = NSLocalizedString(@"Creating Account",@"");
    
    dispatch_queue_t queue = dispatch_queue_create("create_account_with_user_pwd", NULL);
    dispatch_async(queue, ^{
        
        @try{
            // gcd to sign in
            Account *account = [AuthenticationService createNewAccountWithUser:username email:email password:password];
            
            // save the details of account and remove the progress
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // save data to the user information
                [account saveToStandardUserDefaults];
                
                // send notification to the system that it can shows the screen:
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginAuthorize object:nil ];
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            });
        }@catch (NSException* e) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:[e description]];
                [alert showAlert];
            });
            
        }
    });
    dispatch_release(queue);
}
@end

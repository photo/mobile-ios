//
//  LoginConnectViewController.m
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

#import "LoginConnectViewController.h"

@interface LoginConnectViewController ()

@property (nonatomic) BOOL isViewUp;

@end

@implementation LoginConnectViewController
@synthesize email;
@synthesize password;
@synthesize isViewUp = _isViewUp;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title=@"Login";
        self.isViewUp = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.trackedViewName = @"Login Screen";
}

- (void)viewDidUnload
{
    [self setEmail:nil];
    [self setPassword:nil];
    [self setBackgroundEmail:nil];
    [self setBackgroundPassword:nil];
    [super viewDidUnload];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    // if ipad, lets centralize fields
    if([DisplayUtilities isIPad]){
        self.email.center=self.backgroundEmail.center;
        self.password.center=self.backgroundPassword.center;
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(![DisplayUtilities isIPad]){
        if (self.isViewUp == NO){
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
                [self.view setCenter:CGPointMake([self.view  center].x, [self.view center].y - 42)];
            }completion:^(BOOL finished){
                self.isViewUp = YES;
            }];
        }}
}


// Action if user clicks in DONE in the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.email){
        [self.password becomeFirstResponder];
        return NO;
    }else{
        [textField resignFirstResponder];
        [self login:nil];
        return YES;
    }
}
- (IBAction)login:(id)sender {
    // put view down
    if(![DisplayUtilities isIPad]){
        if (self.isViewUp == YES){
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
                [self.view setCenter:CGPointMake([self.view  center].x, [self.view center].y + 42)];
            }completion:^(BOOL finished){
                self.isViewUp = NO;
            }];
        }}
    
    // no keyboard
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    
    //
    // check if email and password is set
    //
    if (self.email.text == nil || [[self.email.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length ] == 0){
        //show message
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Please, set your email.",@"")];
        [alert showAlert];
        return;
        
    }
    if (self.password.text == nil || [[self.password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length ] == 0){
        //show message
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Please, set your password.",@"")];
        [alert showAlert];
        return;
    }
    
    if ( [SharedAppDelegate internetActive] == NO ){
        // problem with internet, show message to user
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Please check your internet connection",@"")];
        [alert showAlert];
    }else{
        
        // display
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = NSLocalizedString(@"Logging",@"");
        
        
        // do it in a queue
        NSString *postEmail =self.email.text;
        NSString *postPassword = self.password.text;
        dispatch_queue_t loggin_account = dispatch_queue_create("logging_account", NULL);
        dispatch_async(loggin_account, ^{
            
            @try{
                // gcd to sign in
                Account *account = [AuthenticationService signIn:postEmail password:postPassword];
                
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
        dispatch_release(loggin_account);
    }
}

- (IBAction)recoverPassword:(id)sender {
    
    // put view down
    if(![DisplayUtilities isIPad]){
        if (self.isViewUp == YES){
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
                [self.view setCenter:CGPointMake([self.view  center].x, [self.view center].y + 42)];
            }completion:^(BOOL finished){
                self.isViewUp = NO;
            }];
        }}
    
    // no keyboard
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    
    if (self.email.text == nil || [[self.email.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length ] == 0){
        //show message
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Please, set your email to recovery password.",@"")];
        [alert showAlert];
        return;
        
    }
    
    if ( [SharedAppDelegate internetActive] == NO ){
        // problem with internet, show message to user
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Please check your internet connection",@"")];
        [alert showAlert];
    }else{
        
        // display
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = NSLocalizedString(@"Resetting",@"Action to reset the pwd");
        
        
        // do it in a queue
        NSString *postEmail =self.email.text;
        dispatch_queue_t reset_user_pwd = dispatch_queue_create("reset_user_pwd", NULL);
        dispatch_async(reset_user_pwd, ^{
            
            @try{
                // gcd to reset
                NSString *messageStatusRecover = [AuthenticationService recoverPassword:postEmail];
                
                // show the message to the user
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    
                    // show message to the user
                    PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:messageStatusRecover];
                    [alert showAlert];
                });
            }@catch (NSException* e) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:[e description]];
                    [alert showAlert];
                });
            }
        });
        dispatch_release(reset_user_pwd);
    }
}

- (IBAction)haveYourOwnInstance:(id)sender {
    AuthenticationViewController *controller = [[AuthenticationViewController alloc]initWithNibName:[DisplayUtilities getCorrectNibName:@"AuthenticationViewController"] bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}
@end

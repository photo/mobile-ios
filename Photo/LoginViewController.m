//
//  LoginViewController.m
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

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // notification user connect via facebook
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(eventHandler:)
                                                     name:kFacebookUserConnected       
                                                   object:nil ];
        
        //register to listen for to remove the login screen.    
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(eventHandler:)
                                                     name:kNotificationLoginAuthorize         
                                                   object:nil ];
        
    }
    return self;
}

-(void) viewDidLoad{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];  
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];  
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)connectUsingFacebook:(id)sender {
    if (![[SharedAppDelegate facebook] isSessionValid]) {
        [[SharedAppDelegate facebook] authorize:[[NSArray alloc] initWithObjects:@"email", nil]];
    }else{
        [self checkUser];
    }
}
- (IBAction)signUpWithEmail:(id)sender {
    LoginCreateAccountViewController *controller = [[LoginCreateAccountViewController alloc] init] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)signInWithEmail:(id)sender {
    LoginConnectViewController *controller = [[LoginConnectViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

//event handler when event occurs
-(void)eventHandler: (NSNotification *) notification
{
    NSLog(@"Event received: %@",notification);
    if ([notification.name isEqualToString:kFacebookUserConnected]){
        [self checkUser];
    }else if ([notification.name isEqualToString:kNotificationLoginAuthorize]){
        // we don't need the screen anymore
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) checkUser{
    
    if ( [SharedAppDelegate internetActive] == NO ){
        // problem with internet, show message to user    
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:@"Failed! Check your internet connection"];
        [alert showAlert];
        return;
    }
    
    // get user email and check if it exists on OpenPhoto
    // display
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [defaults valueForKey:kFacebookUserConnectedEmail];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Checking";
    
    
    // do it in a queue
    dispatch_queue_t checkingEmailFacebook = dispatch_queue_create("checking_email_facebook", NULL);
    dispatch_async(checkingEmailFacebook, ^{
        
        @try{
            BOOL hasAccount = [AuthenticationService checkUserFacebookEmail:email];
            if (hasAccount){
                // just log in
                AccountOpenPhoto *account = [AuthenticationService signIn:email password:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // save the details of account and remove the progress
                    [account saveToStandardUserDefaults];
                    
                    // send notification to the system that it can shows the screen:
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginAuthorize object:nil ];
                    
#ifdef GOOGLE_ANALYTICS_ENABLED
                    NSError *error = nil;
                    if (![[GANTracker sharedTracker] trackEvent:@"ios"
                                                         action:@"track"
                                                          label:@"login"
                                                          value:1
                                                      withError:&error]) {
                        // Handle error here
                    }
#endif
                    
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    // open LoginCreateAccountViewController
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    LoginCreateAccountViewController *controller = [[LoginCreateAccountViewController alloc] init];
                    [controller setFacebookCreateAccount];
                    [self.navigationController pushViewController:controller animated:YES];
                });
            }
        }@catch (NSException* e) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:[e description] duration:5000];
                [alert showAlertOnTop];
            });
        }
    });
    dispatch_release(checkingEmailFacebook);    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

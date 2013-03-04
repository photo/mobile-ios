//
//  LoginViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 02/05/12.
//  Copyright (c) 2013 Trovebox. All rights reserved.
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
    self.trackedViewName = @"Login Screen";
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
    LoginCreateAccountViewController *controller = [[LoginCreateAccountViewController alloc] initWithNibName:[DisplayUtilities getCorrectNibName:@"LoginCreateAccountViewController"] bundle:nil] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)signInWithEmail:(id)sender {
    LoginConnectViewController *controller = [[LoginConnectViewController alloc] initWithNibName:[DisplayUtilities getCorrectNibName:@"LoginConnectViewController"] bundle:nil];
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
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void) checkUser{
    
    if ( [SharedAppDelegate internetActive] == NO ){
        // problem with internet, show message to user
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:@"Please check your internet connection"];
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
                Account *account = [AuthenticationService signIn:email password:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // save the details of account and remove the progress
                    [account saveToStandardUserDefaults];
                    
                    // send notification to the system that it can shows the screen:
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginAuthorize object:nil ];
                    
                    // check point create new account
#ifdef TEST_FLIGHT_ENABLED
                    [TestFlight passCheckpoint:@"Login"];
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
- (void)viewDidUnload {
    [super viewDidUnload];
}
@end

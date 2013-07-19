//
//  AuthenticationViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 07/09/11.
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

#import "AuthenticationViewController.h"

// Private interface definition
@interface AuthenticationViewController()

- (void) saveUrl:(NSString *) text;
- (void) eventHandler: (NSNotification *) notification;

@end

@implementation AuthenticationViewController
@synthesize serverURL = _serverURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //register to listen for to remove the login screen.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(eventHandler:)
                                                     name:kNotificationLoginAuthorize
                                                   object:nil ];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.trackedViewName = @"Self-instance Login Screen";
}

- (void)viewDidUnload
{
    [self setServerURL:nil];
    [self setBackgroundServerUrl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    // if ipad, lets centralize fields
    if([DisplayUtilities isIPad]){
        self.serverURL.center=self.backgroundServerUrl.center;
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

- (IBAction)login:(id)sender {
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Url Login %@",self.serverURL.text);
#endif
    
    // check if the user typed something
    if ( self.serverURL.text != nil &&
        [self.serverURL.text isEqualToString:@"username.trovebox.com"]){
        
        // user should add URL
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Please, set the URL to the Trovebox Server.",@"Used when user don't set the url for the hosted server") duration:5000];
        [alert showAlert];
    }else{
        // save the url method. It removes the last / if exists
        [self saveUrl:self.serverURL.text];
        
        // to the login in the website
        [[UIApplication sharedApplication] openURL:[[[AuthenticationService alloc]init] getOAuthInitialUrl]];
    }
}

// Action if user clicks in DONE in the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Url %@",self.serverURL.text);
#endif
    
    // save the url method. It removes the last / if exists
    [self saveUrl:textField.text];
    
    // to the login
    [[UIApplication sharedApplication] openURL:[[[AuthenticationService alloc]init] getOAuthInitialUrl]];
    
    // return
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        // move the view a little bit up
        [self.view setCenter:CGPointMake([self.view  center].x, [self.view  center].y - 40)];
    }completion:^(BOOL finished){
        if([textField respondsToSelector:@selector(selectedTextRange)]){
            
            //iOS >=5.0
            if ( [textField.text isEqualToString:@"username.trovebox.com"]){
                // get the actual range
                UITextRange *selectedRange = [textField selectedTextRange];
                
                //Calculate the new position, - for left and + for right
                UITextPosition *fromPosition = [textField positionFromPosition:selectedRange.start offset:-21];
                UITextPosition *toPosition = [textField positionFromPosition:selectedRange.start offset:-13];
                
                //Construct a new range and set  in the textfield
                UITextRange *newRange = [textField textRangeFromPosition:fromPosition toPosition:toPosition];
                textField.selectedTextRange = newRange;
            }
        }
    }];
}



///////////////////////////////////
// PRIVATES METHODS
//////////////////////////////////
-(void) saveUrl:(NSString *) text{
    // save the url for the app
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    
    NSURL *url;
    if ([text rangeOfString:@"http://"].location == NSNotFound
        && [text rangeOfString:@"https://"].location == NSNotFound) {
        
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"URL does not contain http:// or https://");
#endif
        
        NSString *urlString = [[NSString alloc] initWithFormat:@"http://%@",text];
        url = [NSURL URLWithString:urlString];
    }else{
        url = [NSURL URLWithString:text];
    }
    
    // removes form the URL if it ends with "/"
    NSString *server;
    if ([[url lastPathComponent] isEqualToString:@"/"]){
        server = [text stringByReplacingCharactersInRange:NSMakeRange(text.length-1, 1) withString:@""];
    }else{
        server = [url relativeString];
    }
    
    [standardUserDefaults setValue:[server lowercaseString] forKey:kTroveboxServer];
    [standardUserDefaults synchronize];
}

//event handler when event occurs
-(void)eventHandler: (NSNotification *) notification
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"###### Event triggered: %@", notification);
#endif
    
    if ([notification.name isEqualToString:kNotificationLoginAuthorize]){
        // we don't need the screen anymore
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

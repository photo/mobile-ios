//
//  AuthenticationViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 07/09/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

#import "AuthenticationViewController.h"

// Private interface definition
@interface AuthenticationViewController() 

- (void) saveUrl:(NSString *) text;
- (BOOL) validateUrl: (NSString *) url;
- (void) eventHandler: (NSNotification *) notification;

@end

@implementation AuthenticationViewController
@synthesize serverURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //register to listen for to remove the login screen.    
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(eventHandler:)
                                                     name:kNotificationLoginAuthorize         
                                                   object:nil ];
        
        //register to listen for to show the login screen.    
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(eventHandler:)
                                                     name:kNotificationLoginNeeded       
                                                   object:nil ];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setServerURL:nil];
    [serverURL release];
    serverURL = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)login:(id)sender {
    
    // check if the user typed something
    if ( serverURL.text != nil &&
        [serverURL.text isEqualToString:@"http://"]){
        
        // user should add URL
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL" message:@"Please, set the URL to the OpenPhoto Server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }else{
        // the same actin as click the button from keyboard
        if ( [self validateUrl:serverURL.text]==YES){
            
            // save the url method. It removes the last / if exists
            [self saveUrl:serverURL.text];
            
            // to the login in the website
            WebService* service = [[WebService alloc]init];
            [[UIApplication sharedApplication] openURL:[service getOAuthInitialUrl]];
            [service release];   
        }
    }
}

// Action if user clicks in DONE in the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {   
    if ([self validateUrl:textField.text] == YES){
        
        // save the url method. It removes the last / if exists
        [self saveUrl:textField.text];
        
        // to the login
        WebService* service = [[WebService alloc]init];
        [[UIApplication sharedApplication] openURL:[service getOAuthInitialUrl]];
        [service release];   
        
        // return
        [textField resignFirstResponder];
        return YES;
    }
    
    return NO;
}


///////////////////////////////////
// PRIVATES METHODS
//////////////////////////////////
- (BOOL) validateUrl: (NSString *) url {
    NSString *theURL =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", theURL]; 
    
    // validate URL
    if ( [urlTest evaluateWithObject:url] == NO){
        // show alert to user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid URL" message:@"Please, try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return NO;
    }
    
    return YES;
}

-(void) saveUrl:(NSString *) text{
    // save the url for the app
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    // removes form the URL if it ends with "/"
    NSURL *url = [NSURL URLWithString:text];
    if ([[url lastPathComponent] isEqualToString:@"/"]){
        [standardUserDefaults setValue:[text stringByReplacingCharactersInRange:NSMakeRange(text.length-1, 1) withString:@""] forKey:kOpenPhotoServer];
    }else{
        [standardUserDefaults setValue:text forKey:kOpenPhotoServer];
    }
    [standardUserDefaults synchronize];  
}

//event handler when event occurs
-(void)eventHandler: (NSNotification *) notification
{
    NSLog(@"event triggered: %@", notification);
    
    if ([notification.name isEqualToString:kNotificationLoginAuthorize]){
        // we don't need the screen anymore
        [self dismissModalViewControllerAnimated:YES];
    }else if ([notification.name isEqualToString:kNotificationLoginNeeded]){
        // show this screen 
        [self presentModalViewController:self animated:YES];
    }
}

- (void)dealloc {
    [serverURL release];
    [super dealloc];
}
@end

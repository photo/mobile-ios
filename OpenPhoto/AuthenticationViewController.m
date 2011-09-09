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
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

// validation
- (BOOL) validateUrl: (NSString *) url;
@end

@implementation AuthenticationViewController
@synthesize serverURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
            
            // save the url for the app
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            [standardUserDefaults setValue:[serverURL.text stringByStandardizingPath] forKey:kOpenPhotoServer];
            [standardUserDefaults synchronize];
            
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
        
        // save the url for the app
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setValue:[textField.text stringByStandardizingPath] forKey:kOpenPhotoServer];
        [standardUserDefaults synchronize];
        
        
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

///////////////////////////////////
// PRIVATES METHODS
//////////////////////////////////
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [connection release];    
    // result
    NSString *string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    // For Step 1: Result = oauth_token=token&type=unauthorized
    NSLog(@"Result = %@",string);
    
    // it can be released
    [responseData release];
}


- (void)dealloc {
    [serverURL release];
    [super dealloc];
}
@end

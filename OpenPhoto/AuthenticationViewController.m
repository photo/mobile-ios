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
    NSLog(@"Url Login %@",serverURL.text);
    
    // check if the user typed something
    if ( serverURL.text != nil &&
        [serverURL.text isEqualToString:@"username.openphoto.me"]){
        
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
    
#ifdef TEST_FLIGHT_ENABLED
    [TestFlight passCheckpoint:@"User click login"];
#endif
}

- (IBAction)getNewAccount:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://openphoto.me"]];
}

// Action if user clicks in DONE in the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {  
    NSLog(@"Url %@",serverURL.text);
    
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

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if ( [textField.text isEqualToString:@"username.openphoto.me"]){
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



///////////////////////////////////
// PRIVATES METHODS
//////////////////////////////////
- (BOOL) validateUrl: (NSString *) url {
    
    
    NSString *theURL =
    @"((http|https)://)?((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
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
    
    
    NSURL *url;
    if ([text rangeOfString:@"http://"].location == NSNotFound) {
        NSLog(@"URL does not contain http://");
        NSString *urlString = [[NSString alloc] initWithFormat:@"http://%@",text];
        url = [NSURL URLWithString:urlString];
    }else{
        url = [NSURL URLWithString:text];
    }
    
    // removes form the URL if it ends with "/"
    if ([[url lastPathComponent] isEqualToString:@"/"]){
        [standardUserDefaults setValue:[text stringByReplacingCharactersInRange:NSMakeRange(text.length-1, 1) withString:@""] forKey:kOpenPhotoServer];
    }else{
        [standardUserDefaults setValue:[url relativeString] forKey:kOpenPhotoServer];
    }
    [standardUserDefaults synchronize];  
}

//event handler when event occurs
-(void)eventHandler: (NSNotification *) notification
{
    NSLog(@"###### Event triggered: %@", notification);
    if ([notification.name isEqualToString:kNotificationLoginAuthorize]){
        // we don't need the screen anymore
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)dealloc {
    [serverURL release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
@end

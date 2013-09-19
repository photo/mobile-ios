//
//  LoginViewController.m
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

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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

-(void) viewDidLoad{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.trackedViewName = @"Login Screen";
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - Rotation

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
    if ([notification.name isEqualToString:kNotificationLoginAuthorize]){
        // we don't need the screen anymore
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}
@end

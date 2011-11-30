//
//  OpenPhotoIASKAppSettingsViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 29/10/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

#import "OpenPhotoIASKAppSettingsViewController.h"

@implementation OpenPhotoIASKAppSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"BackgroundUpload.png"]];

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
	[super viewWillAppear:animated];
    
    // add logt out
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButton)];          
    self.navigationItem.rightBarButtonItem = logoutButton;
    [logoutButton release];
}		
    
- (void) logoutButton{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Are you sure?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log out",nil] autorelease];
    [alert show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1){
        NSLog(@"Invalidate user information");
        AuthenticationHelper* helper = [[AuthenticationHelper alloc]init];
        [helper invalidateAuthentication];
        [helper release];
    }
}

@end

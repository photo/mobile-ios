//
//  FriendDetailsViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 05/02/14.
//  Copyright 2014 Trovebox
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

#import "FriendDetailsViewController.h"

@interface FriendDetailsViewController ()
- (void) loadUserDetails;
@property (nonatomic, strong) Friend *friend;
@end

@implementation FriendDetailsViewController

@synthesize friend=_friend;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil friend:(Friend*) frnd
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor blackColor];
        self.tabBarItem.title=NSLocalizedString(@"Friend",@"Title screen Friend");
        self.title=NSLocalizedString(@"Friend",@"Title screen Friend");
        self.hidesBottomBarWhenPushed = NO;
        self.wantsFullScreenLayout = YES;
        self.view.backgroundColor =  UIColorFromRGB(0XFAF3EF);
        
        //set friend
        _friend=frnd;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=NSLocalizedString(@"Friend",@"Title screen Friend");
    self.screenName = @"Friend Screen";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // image for the navigator
    [self.navigationController.navigationBar troveboxStyle:NO];
    
    // title and buttons
    [self.navigationItem troveboxStyle:NSLocalizedString(@"Friends", @"Menu - title for Friends") defaultButtons:NO viewController:nil menuViewController:nil];
    
    // menu
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButtonImage = [UIImage imageNamed:@"button-navigation-menu.png"] ;
    [leftButton setImage:leftButtonImage forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(0, 0, leftButtonImage.size.width, leftButtonImage.size.height);
    [leftButton addTarget:self.viewDeckController  action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customLeftButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = customLeftButton;
    
    // load the data from the server and show in the screen
    [self loadUserDetails];
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

- (void) loadUserDetails
{
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Loading Profile details");
#endif
    
    if ( [SharedAppDelegate internetActive] == NO ){
        // problem with internet, show message to user
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Please check your internet connection",@"")];
        [alert showAlert];
    }else if ([AuthenticationService isLogged]){
        
        // display
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"Refreshing";
        
        dispatch_queue_t get_user_details = dispatch_queue_create("get_user_details", NULL);
        dispatch_async(get_user_details, ^{
            
            @try{
                WebService *service = [[WebService alloc] init];
                NSDictionary *rawAnswer = [service getUserDetailsForSite:self.friend.host];
                NSDictionary *result = [rawAnswer objectForKey:@"result"];
                
                // display details
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([result class] != [NSNull class]) {
                        
                        // name
                        NSString *name = [result objectForKey:@"name"];
                        [self.labelName setText:name];
                        // url thumb
                        [self.photo  setImageWithURL:[NSURL URLWithString:[result objectForKey:@"photoUrl"]]
                                    placeholderImage:nil
                                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                                               if (error){
                                                   PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Couldn't download the image",@"message when couldn't download the image in the profile screen") duration:5000];
                                                   [alert showAlert];
#ifdef DEVELOPMENT_ENABLED
                                                   NSLog(@"URL failed to load %@", [result objectForKey:@"photoUrl"]);
#endif
                                               }else{
                                                   // Begin a new image that will be the new image with the rounded corners
                                                   // (here with the size of an UIImageView)
                                                   UIGraphicsBeginImageContextWithOptions(self.photo.bounds.size, NO, 1.0);
                                                   
                                                   // Add a clip before drawing anything, in the shape of an rounded rect
                                                   [[UIBezierPath bezierPathWithRoundedRect:self.photo.bounds
                                                                               cornerRadius:10.0] addClip];
                                                   // Draw your image
                                                   [image drawInRect:self.photo.bounds];
                                                   
                                                   // Get the image, here setting the UIImageView image
                                                   self.photo.image = UIGraphicsGetImageFromCurrentImageContext();
                                                   
                                                   // Lets forget about that we were drawing
                                                   UIGraphicsEndImageContext();
                                               }
                                           }];
                        
                        NSDictionary* counts = [result objectForKey:@"counts"];
                        // albums
                        [self.labelAlbums setText:[NSString stringWithFormat:@"%@", [counts objectForKey:@"albums"]]];
                        // photos
                        [self.labelPhotos setText:[NSString stringWithFormat:@"%@", [counts objectForKey:@"photos"]]];
                    }
                    
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
    }
    
}

- (void)viewDidUnload {
    [self setLabelAlbums:nil];
    [self setLabelPhotos:nil];
    [self setLabelName:nil];
    [self setPhoto:nil];
    [super viewDidUnload];
}

- (IBAction)showPhotos:(id)sender {
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Show photos");
#endif
}

- (IBAction)showAlbums:(id)sender {
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Show albums");
#endif
}
@end

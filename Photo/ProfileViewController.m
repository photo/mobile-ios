//
//  ProfileViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 05/02/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()
- (void) loadUserDetails;
- (void) formatStorage:(long long) storage;
@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor blackColor];
        self.tabBarItem.title=NSLocalizedString(@"Profile",@"Title screen Profile");
        self.title=NSLocalizedString(@"Profile",@"Title screen Profile");
        self.hidesBottomBarWhenPushed = NO;
        self.wantsFullScreenLayout = YES;
        self.view.backgroundColor =  UIColorFromRGB(0XFAF3EF);
        
        
        // needs update in screen
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(eventHandler:)
                                                     name:kInAppPurchaseManagerProductsFetchedNotification
                                                   object:nil ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=NSLocalizedString(@"Profile",@"Title screen Profile");
    self.trackedViewName = @"Profile Screen";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // menu
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButtonImage = [UIImage imageNamed:@"button-navigation-menu.png"] ;
    [leftButton setImage:leftButtonImage forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(0, 0, leftButtonImage.size.width, leftButtonImage.size.height);
    [leftButton addTarget:self.viewDeckController  action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customLeftButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = customLeftButton;
        
    // add log out
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [UIImage imageNamed:@"logout.png"] ;
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:self action:@selector(logoutButton) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = logoutButton;
    
    // image for the navigator
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]){
        //iOS >=5.0
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"appbar_empty.png"] forBarMetrics:UIBarMetricsDefault];
    }else{
        UIImageView *imageView = (UIImageView *)[self.navigationController.navigationBar viewWithTag:6183746];
        if (imageView == nil)
        {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appbar_empty.png"]];
            [imageView setTag:6183746];
            [self.navigationController.navigationBar insertSubview:imageView atIndex:0];
        }
    }
    
    // load the data from the server and show in the screen
    [self loadUserDetails];
}

- (void) logoutButton{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Log out. Are you sure?",@"Message to confirm if user really wants to log out") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"") otherButtonTitles:NSLocalizedString(@"Log out",@""),nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1){
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Invalidate user information");
#endif
        
        AuthenticationService* helper = [[AuthenticationService alloc]init];
        [helper logout];
    }
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
                NSDictionary *rawAnswer = [service getUserDetails];
                NSDictionary *result = [rawAnswer objectForKey:@"result"];
                
                // display details
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([result class] != [NSNull class]) {
                        
                        // email
                        [self.labelServer setText:[result objectForKey:@"email"]];
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

                        // paid user
                        if ([[result objectForKey:@"paid"] boolValue])
                            [self.labelAccount setText:NSLocalizedString(@"Pro",@"Profile - Pro text")];
                        else
                            [self.labelAccount setText:NSLocalizedString(@"Free",@"Profile - Free text")];
                        
                        
                        NSDictionary* counts = [result objectForKey:@"counts"];
                        // albums
                        [self.labelAlbums setText:[NSString stringWithFormat:@"%@", [counts objectForKey:@"albums"]]];
                        // photos
                        [self.labelPhotos setText:[NSString stringWithFormat:@"%@", [counts objectForKey:@"photos"]]];
                        
                        // storage
                        NSString *storage = [counts objectForKey:@"storage_str"];
                        if (storage != nil){
                            [self formatStorage:[storage longLongValue]];
                        }
                        
                        // tags
                        [self.labelTags setText:[NSString stringWithFormat:@"%@",[counts objectForKey:@"tags"]]];
                        
                        // limits
                        NSDictionary* limits = [result objectForKey:@"limit"];
                        
                        // save details locally
                        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                        [standardUserDefaults setValue:name forKey:kTroveboxNameUser];
                        [standardUserDefaults setValue:[result objectForKey:@"email"] forKey:kTroveboxEmailUser];
                        [standardUserDefaults setValue:[NSDate date] forKey:kProfileLatestUpdateDate];
                        [standardUserDefaults setValue:[result objectForKey:@"paid"] forKey:kProfileAccountType];
                        [standardUserDefaults setValue:[limits objectForKey:@"remaining"] forKey:kProfileLimitRemaining];
                        [standardUserDefaults setValue:[limits objectForKey:@"allowed"] forKey:kProfileLimitAllowed];
                        
                        [standardUserDefaults synchronize];
                    }
                    
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    
                    if ([SKPaymentQueue canMakePayments]) {
                        if ([[result objectForKey:@"paid"] boolValue]){
                            // PRO User, don't show button or label
                            self.labelPriceSubscription.hidden = TRUE;
                            self.buttonSubscription.hidden = TRUE;
                            self.buttonFeatureList.hidden = TRUE;
                        }else{
                            // set the value
                            TroveboxSubscription *subscription = [TroveboxSubscription createTroveboxSubscription];
                            SKProduct *product = [subscription product];
                            if( product.price != nil){
                                [self.labelPriceSubscription setText:[NSString stringWithFormat:@"%@ %@/%@", NSLocalizedString(@"Just",@"Profile - subscription"), [product localizedPrice], NSLocalizedString(@"month",@"Profile - subscription")]];
                                self.buttonFeatureList.hidden = FALSE;
                                self.labelPriceSubscription.hidden = FALSE;
                                self.buttonSubscription.hidden = FALSE;
                            }}
                    }else{
                        // Warn the user that purchases are disabled.
                        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage: NSLocalizedString(@"App can't do Purchase. Please, check Settings if you want to upgrade the app",@"Message when user can not purchase") duration:7000];
                        [alert showAlert];
                        
                        [self.buttonSubscription setHidden:YES];
                        [self.labelPriceSubscription setHidden:YES];
                    }
                });
            }@catch (NSException* e) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:[e description]];
                    [alert showAlert];
                });
                
            }
        });
        dispatch_release(get_user_details);
    }
    
}

- (IBAction)subscribe:(id)sender {
    
    if ([SKPaymentQueue canMakePayments]) {
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:kInAppPurchaseProUpgradeProductId];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    }
}

- (IBAction)openFeaturesList:(id)sender
{
    // open a web view for the link: https://trovebox.com/plans/mobile
    WebViewController* webViewController = [[WebViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void) formatStorage:(long long) storage
{
    int kb = 1024;
    
    // less than 1mb
    if(storage < 1048576){
        storage = ceil(storage/kb);
        [self.labelStorage setText:[NSString stringWithFormat:@"%llu",storage]];
        [self.labelStorageDetails setText:NSLocalizedString(@"KB used",@"Profile - size storage")];
    }else if(storage < 1073741824){
        // less than 1gb
        storage = ceil(storage/pow(kb,2));
        [self.labelStorage setText:[NSString stringWithFormat:@"%llu",storage]];
        [self.labelStorageDetails setText:NSLocalizedString(@"MB used",@"Profile - size storage")];
    }else{
        storage = ceil(storage/pow(kb,3));
        [self.labelStorage setText:[NSString stringWithFormat:@"%llu",storage]];
        [self.labelStorageDetails setText:NSLocalizedString(@"GB used",@"Profile - size storage")];
    }
}

- (void) eventHandler: (NSNotification *) notification{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"###### Event triggered: %@", notification);
#endif
    
    if ([notification.name isEqualToString:kInAppPurchaseManagerProductsFetchedNotification]){
        [self loadUserDetails];
    }
}

- (void)viewDidUnload {
    [self setLabelAlbums:nil];
    [self setLabelPhotos:nil];
    [self setLabelTags:nil];
    [self setLabelStorage:nil];
    
    [self setLabelName:nil];
    [self setPhoto:nil];
    [self setLabelStorageDetails:nil];
    [self setLabelServer:nil];
    [self setLabelAccount:nil];
    [self setLabelPriceSubscription:nil];
    [self setButtonSubscription:nil];
    [self setButtonFeatureList:nil];
    [super viewDidUnload];
}
@end

//
//  HomeViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 26/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "HomeViewController.h"

// Private interface definition
@interface HomeViewController() 
- (void) showPictures;
- (void) checkRefreshPictures: (NSNotification *) notification;
- (void) refreshPictures: (NSNotification *) notification;
@end


@implementation HomeViewController

@synthesize service, homeImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
        self.tabBarItem.image=[UIImage imageNamed:@"tab-home.png"];
        self.tabBarItem.title=@"Home";
        self.title=@"Open Photo";
        
        // create service and the delegate
        self.service = [[WebService alloc]init];
        [service setDelegate:self];
        
        CGRect imageSize = CGRectMake(0, 46, 320, 431); // 431 because we have the TAB BAR 
        self.homeImageView = [[UIImageView alloc] initWithFrame:imageSize];
        
        // create notification to update the pictures
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(checkRefreshPictures:)
                                                     name:kNotificationCheckRefreshPictures         
                                                   object:nil ];
        
        //   create notification to update the pictures without checking timer
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(refreshPictures:)
                                                     name:kNotificationRefreshPictures         
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

// delegate
-(void) receivedResponse:(NSDictionary *)response{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // check if message is valid
    if (![WebService isMessageValid:response]){
        NSString* message = [WebService getResponseMessage:response];
        NSLog(@"Invalid response = %@",message);
        
        // show alert to user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Response Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    NSArray *photos = [response objectForKey:@"result"] ;
    
    // check if user has photos
    if ([photos class] != [NSNull class]) {
        // do the download in a thread
        // to send the request we add a thread.
        [NSThread detachNewThreadSelector:@selector(getHomeScreenPicturesOnDetachTread:) 
                                 toTarget:self 
                               withObject:photos];
    }else{
        // no picture - save timestamp
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setObject: [NSDate date] forKey:kHomeScreenPicturesTimestamp];
        [standardUserDefaults synchronize];
        [self showPictures];
    }
    
    
}

-(void) getHomeScreenPicturesOnDetachTread:(NSArray*) photos
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *key;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
        // retina display
        key = [[NSString alloc]initWithString:@"path640x770xCR"];
    }else{
        // not retina display
        key = [[NSString alloc]initWithString:@"path320x385xCR"];
    }
    
    // Loop through each entry in the dictionary and create an array of MockPhoto
    if (photos != nil && [photos count]>0){
        NSMutableArray *images = [NSMutableArray array];
        for (NSDictionary *photo in photos){
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [photo objectForKey:key]]]];
            
            if (data != nil)
                [images addObject:data];
            else
                NSLog(@"Object photo not found %@",[NSString stringWithFormat:@"%@", [photo objectForKey:key]] );
        } 
        
        // save the pictures into user defaults
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setObject:images forKey:kHomeScreenPictures];
        
        // save timestamp
        [standardUserDefaults setObject: [NSDate date] forKey:kHomeScreenPicturesTimestamp];
        [standardUserDefaults synchronize];
        
        // can be updated
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCheckRefreshPictures object:nil ];
    }
    
    [key release];
    [pool release];
    
}

- (void) viewDidLoad{
    // load the logo
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appbar_logo.png"]];
    CGRect positionLogo = CGRectMake(0, 0, 320, 46);
    [logo setFrame:positionLogo];
    [self.view addSubview:logo];
    [logo release];
}

#pragma mark - View lifecycle
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];  
    
    // load some pictures if the timestamp is null or it is older than one hour
    NSDate *now = [NSDate date];
    NSDate *old = [[NSUserDefaults standardUserDefaults] objectForKey:kHomeScreenPicturesTimestamp];
    
    // if there is internet. Because it is the first screen, it is possible that the internet is not reachability yet
    if (service.internetActive == YES && service.hostActive == YES){
        if (old == nil){
            NSLog(@"First time that the application is running.");
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [service getHomePictures];  
        }else if ([now timeIntervalSinceDate:old] > 3600){
            // one hour after the last update
            NSLog(@"The last update of pictures was one hour ago");
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [service getHomePictures];  
        }else{
            NSLog(@"It is not necessary to get the home pictures");
            [self.homeImageView startAnimating];
        }
    }else{
        NSLog(@"Internet is not reacheable yet");
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCheckRefreshPictures object:nil ];
    }
    
    
#ifdef TEST_FLIGHT_ENABLED
    [TestFlight passCheckpoint:@"Home pictures"];
#endif
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];  
    [self.homeImageView stopAnimating];
}

- (void) checkRefreshPictures: (NSNotification *) notification{
    [self showPictures];
}

- (void) refreshPictures: (NSNotification *) notification{
    // clean images saved localy
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setValue:nil forKey:kHomeScreenPicturesTimestamp];
    [standardUserDefaults setValue:nil forKey:kHomeScreenPictures];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [service getHomePictures]; 
}


- (void) showPictures{
    NSMutableArray *images = [NSMutableArray array];
    
    // get the local pictures
    NSMutableArray *rawImages = [[NSUserDefaults standardUserDefaults] objectForKey:kHomeScreenPictures];
    if (rawImages != nil){
        
        if ([rawImages count] > 0){
            // user has pictures
            for (NSData *rawImage in rawImages){
                UIImage *img = [[UIImage alloc] initWithData:rawImage];
                
                
                
                
                [images addObject:[img autorelease]];
            }
        }
    }else{
        // show message to start uploading pictures
        UIImage *img = [UIImage imageNamed:@"upload.png"];
        [images addObject:img];
    }
    
    // show the pictures  
    // remove from superview if it is there
    if([self.homeImageView superview])
        [self.homeImageView removeFromSuperview];
    
    
    CGRect imageSize = CGRectMake(0, 46, 320, 431); // 431 because we have the TAB BAR 
    self.homeImageView = [[UIImageView alloc] initWithFrame:imageSize];
    self.homeImageView.animationImages = images;
    self.homeImageView.animationDuration = 20; // seconds
    self.homeImageView.animationRepeatCount = 0; // 0 = loops forever
    [self.homeImageView startAnimating];
    [self.view addSubview:self.homeImageView];
}

- (void) notifyUserNoInternet{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // problem with internet, show message to user
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet error" message:@"Couldn't reach the server. Please, check your internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc {
    [service release];
    [homeImageView release];
    [super dealloc];
}

@end

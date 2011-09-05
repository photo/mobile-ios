//
//  HomeViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 26/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "HomeViewController.h"

@implementation HomeViewController

@synthesize service;
@synthesize images;

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
        
        self.images = [[NSMutableArray alloc] init];  
        
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
    NSArray *photos = [response objectForKey:@"result"] ;
    // do the download in a thread
    // to send the request we add a thread.
    [NSThread detachNewThreadSelector:@selector(getHomeScreenPicturesOnDetachTread:) 
                             toTarget:self 
                           withObject:photos];
    
    
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
    if (photos != nil){
        for (NSDictionary *photo in photos){
            NSLog(@"Photo URL = %@",[photo objectForKey:key]);
            UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [photo objectForKey:key]]]]];
            [images addObject:[img autorelease]];
        } 
        
        UIImageView *animationView = [UIImageView alloc];
        CGRect imageSize = CGRectMake(0, 46, 320, 431); // 431 because we have the TAB BAR 
        [animationView initWithFrame:imageSize];
        animationView.animationImages = images;
        animationView.animationDuration = 17; // seconds
        animationView.animationRepeatCount = 0; // 0 = loops forever
        [animationView startAnimating];
        [self.view addSubview:animationView];
        [animationView release]; 
    }
    
    [key release];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [pool release];
    
}

#pragma mark - View lifecycle
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];  
    
    // load the logo
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appbar_logo.png"]];
    CGRect positionLogo = CGRectMake(0, 0, 320, 46);
    [logo setFrame:positionLogo];
    [self.view addSubview:logo];
    
    // load some pictures
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [service getHomePictures];  
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc {
    [service release];
    [images release];
    [super dealloc];
}

@end

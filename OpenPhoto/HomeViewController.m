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
        service = [[WebService alloc]init];
        [service setDelegate:self];
        
        images = [[NSMutableArray alloc] init];  
        
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
        int i =0; // needs to be removed after bug is fixed
        for (NSDictionary *photo in photos){
            
            NSLog(@"Photo URL = %@",[photo objectForKey:key]);
            UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [photo objectForKey:key]]]]];
            [images addObject:[img autorelease]];
            i++;
            
            if (i == 4){
                break;
            }
        } 
        
        UIImageView *myAnimatedView = [UIImageView alloc];
        CGRect myImageRect = CGRectMake(0, 46, 320, 431); // 431 because we have the TAB BAR 
        [myAnimatedView initWithFrame:myImageRect];
        myAnimatedView.animationImages = images;
        myAnimatedView.animationDuration = 17; // seconds
        myAnimatedView.animationRepeatCount = 0; // 0 = loops forever
        [myAnimatedView startAnimating];
        [self.view addSubview:myAnimatedView];
        [myAnimatedView release]; 
        
    }
    
    [key release];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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

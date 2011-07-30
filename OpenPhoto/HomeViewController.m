//
//  HomeViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 26/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "HomeViewController.h"

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
        self.tabBarItem.image=[UIImage imageNamed:@"tab-home.png"];
        self.tabBarItem.title=@"Home";
        self.title=@"Open Photo";
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
        [super viewDidLoad];
    
    
    NSArray *myImages = [NSArray arrayWithObjects:
                         [UIImage imageNamed:@"picture1.jpg"],
                         [UIImage imageNamed:@"picture2.png"],
                         [UIImage imageNamed:@"picture3.jpg"],
                         nil];
    
    UIImageView *myAnimatedView = [UIImageView alloc];
    CGRect myImageRect = CGRectMake(10, 10, 200, 200);
    [myAnimatedView initWithFrame:myImageRect];
    myAnimatedView.animationImages = myImages;
    myAnimatedView.animationDuration = 7; // seconds
    myAnimatedView.animationRepeatCount = 0; // 0 = loops forever
    myAnimatedView.contentMode = UIViewContentModeScaleAspectFit;
    [myAnimatedView startAnimating];
    [self.view addSubview:myAnimatedView];
    [myAnimatedView release]; 
    
    
    NSArray *myImages2 = [NSArray arrayWithObjects:
                         [UIImage imageNamed:@"picture3.jpg"],
                         [UIImage imageNamed:@"picture1.jpg"],
                         [UIImage imageNamed:@"picture2.png"],
                         nil];
    
    UIImageView *myAnimatedView2 = [UIImageView alloc];
    CGRect myImageRect2 = CGRectMake(100, 100, 250, 250);
    [myAnimatedView2 initWithFrame:myImageRect2];
    myAnimatedView2.animationImages = myImages2;
    myAnimatedView2.animationDuration = 6; // seconds
    myAnimatedView2.animationRepeatCount = 0; // 0 = loops forever
    myAnimatedView2.contentMode = UIViewContentModeScaleAspectFit;
    [myAnimatedView2 startAnimating];
    [self.view addSubview:myAnimatedView2];
    [myAnimatedView2 release]; 

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

//
//  MainHomeViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 22/03/12.
//  Copyright 2012 OpenPhoto
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

#import "MainHomeViewController.h"

@interface MainHomeViewController ()

@property (nonatomic,retain,readwrite) NewestPhotosTableViewController *newestPhotosViewController;
@property (nonatomic,retain,readwrite)  ActivityFeedViewController *activityFeedViewController;
- (void)didChangeSegmentControl:(UISegmentedControl *)control;
@end

@implementation MainHomeViewController

@synthesize segmentedControl;
@synthesize currentImageView;
@synthesize newestPhotosViewController,activityFeedViewController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.newestPhotosViewController = [[NewestPhotosTableViewController alloc]init];
        self.activityFeedViewController = [[ActivityFeedViewController alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.activityFeedViewController isViewLoaded])
        [self.activityFeedViewController.view removeFromSuperview];
    
    [self.currentImageView addSubview:self.newestPhotosViewController.view]; 

    [self.segmentedControl addTarget:self
                              action:@selector(didChangeSegmentControl:)
                    forControlEvents:UIControlEventValueChanged];

    // start with the newest photos
    self.segmentedControl.selectedSegmentIndex = 0;
}

- (void)didChangeSegmentControl:(UISegmentedControl *)control {   
    if (control.selectedSegmentIndex == 0){
        if ([self.activityFeedViewController isViewLoaded])
            [self.activityFeedViewController.view removeFromSuperview];
        
        [self.currentImageView addSubview:self.newestPhotosViewController.view]; 
    }else {
        if ([self.newestPhotosViewController isViewLoaded])
            [self.newestPhotosViewController.view removeFromSuperview];
        
        [self.currentImageView addSubview:self.activityFeedViewController.view]; 
    }
    
    [self.currentImageView setNeedsDisplay];
}


- (void)viewDidUnload
{
    [self setSegmentedControl:nil];
    [self setCurrentImageView:nil];
    self.newestPhotosViewController = nil;
    self.activityFeedViewController = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [segmentedControl release];
    [currentImageView release];
    [newestPhotosViewController release];
    [activityFeedViewController release];
    [super dealloc];
}
@end

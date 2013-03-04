//
//  AccountViewController.m
//  Photo
//
//  Created by Patrick Santana on 29/10/12.
//  Copyright 2012 Photo
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



#import "AccountViewController.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleLeftView)];
    
    if ([self.navigationItem respondsToSelector:@selector(rightBarButtonItems)]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
                                                   [[UIBarButtonItem alloc] initWithTitle:@"Sync" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleRightView)],
                                                   nil];
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sync" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleRightView)];
    }
    
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
    
    self.view.backgroundColor = UIColorFromRGB(0xFFCC00);
    // title
    self.navigationItem.title = NSLocalizedString(@"Account", @"Menu - title for Account");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

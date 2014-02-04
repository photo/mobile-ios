//
//  WebViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 26/02/13.
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

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController
@synthesize m_cWebView=_m_cWebView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor blackColor];
        self.tabBarItem.title=NSLocalizedString(@"Plans",@"Profile - plans web controller");
        self.title=NSLocalizedString(@"Plans",@"Profile - plans web controller");
        self.hidesBottomBarWhenPushed = NO;
        self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (void)loadView
{
    CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
    webFrame.size.height -= self.navigationController.navigationBar.frame.size.height;
    UIWebView *pWebView = [[UIWebView alloc] initWithFrame:webFrame];
    pWebView.autoresizesSubviews = YES;
    pWebView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.view = pWebView;
    pWebView.scalesPageToFit = YES;
    self.m_cWebView = pWebView;
    
    self.view.backgroundColor =  UIColorFromRGB(0XFAF3EF);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if( self.m_cWebView != nil )
    {
        NSURL *url = [NSURL URLWithString:@"https://trovebox.com/plans/mobile"];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [self.m_cWebView loadRequest:request];
    }
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

@end

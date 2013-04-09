//
//  WebViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 26/02/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
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
        self.tabBarItem.title=@"Plans";
        self.title=@"Plans";
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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIButton *buttonSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImageSettings = [UIImage imageNamed:@"back.png"] ;
    [buttonSettings setImage:buttonImageSettings forState:UIControlStateNormal];
    buttonSettings.frame = CGRectMake(0, 0, buttonImageSettings.size.width, buttonImageSettings.size.height);
    [buttonSettings addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItemRefresh = [[UIBarButtonItem alloc] initWithCustomView:buttonSettings];
    self.navigationItem.leftBarButtonItem = customBarItemRefresh;}

- (void) goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

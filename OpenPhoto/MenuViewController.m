//
//  MenuViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 26/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "MenuViewController.h"

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIViewController *home = [[[UIViewController alloc] init] autorelease];
    home.view.backgroundColor = [UIColor redColor];
    home.tabBarItem.image=[UIImage imageNamed:@"tab-home.png"];
    home.title=@"Home";
    
    UIViewController *tags = [[[UIViewController alloc] init] autorelease];
    tags.view.backgroundColor = [UIColor blackColor];
    tags.tabBarItem.image=[UIImage imageNamed:@"tab-tags.png"];
    tags.title=@"Tags";

    UIViewController *photo = [[[UIViewController alloc] init] autorelease];
    photo.view.backgroundColor = [UIColor cyanColor];
    photo.tabBarItem.image=[UIImage imageNamed:@"tab-picture.png"];
    photo.title=@"Photo";
    
    UIViewController *gallery = [[[UIViewController alloc] init] autorelease];
    gallery.view.backgroundColor = [UIColor greenColor];
    gallery.tabBarItem.image=[UIImage imageNamed:@"tab-gallery.png"];
    gallery.title=@"Gallery";
    
    UIViewController *settings = [[[UIViewController alloc] init] autorelease];
    settings.view.backgroundColor = [UIColor blueColor];
    settings.tabBarItem.image=[UIImage imageNamed:@"tab-settings.png"];
    settings.title=@"Settings";    
    
    self.viewControllers = [NSArray arrayWithObjects:home,tags,photo,gallery,settings,nil];
}

@end

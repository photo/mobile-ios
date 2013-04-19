//
//  UINavigationItem+Trovebox.m
//  Trovebox
//
//  Created by Patrick Santana on 19/04/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "UINavigationItem+Trovebox.h"

@implementation UINavigationItem (Trovebox)

- (void)troveboxStyle:(NSString *) name defaultButtons:(BOOL) defaultButtonsEnabled viewController:(UIViewController*) controller menuViewController:(MenuViewController*) menuViewController
{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor]; // change this color
    label.text = name;
    [label sizeToFit];
    self.titleView = label;
    
    if (defaultButtonsEnabled){
        // menu
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *leftButtonImage = [UIImage imageNamed:@"button-navigation-menu.png"] ;
        [leftButton setImage:leftButtonImage forState:UIControlStateNormal];
        leftButton.frame = CGRectMake(0, 0, leftButtonImage.size.width, leftButtonImage.size.height);
        [leftButton addTarget:controller  action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *customLeftButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        self.leftBarButtonItem = customLeftButton;
        
        // camera
        UIButton *buttonRight = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *buttonRightImage = [UIImage imageNamed:@"button-navigation-camera.png"] ;
        [buttonRight setImage:buttonRightImage forState:UIControlStateNormal];
        buttonRight.frame = CGRectMake(0, 0, buttonRightImage.size.width, buttonRightImage.size.height);
        [buttonRight addTarget:menuViewController action:@selector(openCamera:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *customRightButton = [[UIBarButtonItem alloc] initWithCustomView:buttonRight];
        self.rightBarButtonItem = customRightButton;

    }
}

@end

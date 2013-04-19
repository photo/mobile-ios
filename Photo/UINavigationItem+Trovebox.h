//
//  UINavigationItem+Trovebox.h
//  Trovebox
//
//  Created by Patrick Santana on 19/04/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationItem (Trovebox)


- (void)troveboxStyle:(NSString *) name defaultButtons:(BOOL) defaultButtonsEnabled viewController:(UIViewController*) controller menuViewController:(MenuViewController*) menuViewController;

@end

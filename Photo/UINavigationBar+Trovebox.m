//
//  UINavigationBar+Trovebox.m
//  Trovebox
//
//  Created by Nico Prananta on 4/7/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "UINavigationBar+Trovebox.h"

@implementation UINavigationBar (Trovebox)

- (void)troveboxStyle {
    // image for the navigator
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]){
        //iOS >=5.0
        [self setBackgroundImage:[UIImage imageNamed:@"appbar_empty.png"] forBarMetrics:UIBarMetricsDefault];
    }else{
        UIImageView *imageView = (UIImageView *)[self viewWithTag:6183746];
        if (imageView == nil)
        {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appbar_empty.png"]];
            [imageView setTag:6183746];
            [self insertSubview:imageView atIndex:0];
        }
    }
}

@end

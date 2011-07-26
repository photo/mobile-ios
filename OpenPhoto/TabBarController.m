//
//  TabBarController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 26/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "TabBarController.h"


@implementation TabBarController

- (void)viewDidLoad {
    [self setTabURLs:[NSArray arrayWithObjects:@"openphoto://home",
                      @"openphoto://gallery",
                      nil]];
    
    self.selectedIndex=0;
}

@end

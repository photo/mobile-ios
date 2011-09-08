//
//  AuthenticationViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 07/09/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthenticationViewController : UIViewController{
    NSMutableData *responseData;
}

- (IBAction)login:(id)sender;

@end

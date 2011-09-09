//
//  AuthenticationViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 07/09/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebService.h"

@interface AuthenticationViewController : UIViewController<UITextFieldDelegate>{
    NSMutableData *responseData;
}
@property (retain, nonatomic) IBOutlet UITextField *serverURL;

- (IBAction)login:(id)sender;

@end

//
//  FirstViewController.h
//  BasicExample
//
//  Created by Farooq Mela on 4/10/12.
//  Copyright 2012 Google, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController {
 @private
  UIButton *button_;
}

@property (nonatomic, assign) IBOutlet UIButton *button;

- (IBAction)buttonClicked:(id)sender;

@end

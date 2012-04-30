//
//  OpenPhotoAlertView.m
//  OPMEAlert
//
//  Created by Patrick Santana on 23/04/12.
//  Copyright 2012 OpenPhoto
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


#import "OpenPhotoAlertView.h"


@interface OpenPhotoAlertView(){
    UIView *viewAlert;
    NSString *message;
    NSInteger  duration;
}

- (void)showOnTop:(BOOL) top;

@property (nonatomic, retain) UIView *viewAlert;
@property (nonatomic, retain) NSString *message;
@property (assign) NSInteger duration;

@end

@implementation OpenPhotoAlertView
@synthesize viewAlert = _viewAlert;
@synthesize message = message;
@synthesize duration = _duration;


- (id) initWithMessage:(NSString *) text duration:(NSInteger) time{
	if (self = [super init]) {
		self.message = text;
        self.duration = time;
	}
    
	return self;
}

- (void) showAlertOnTop{
    [self showOnTop:YES];    
}

- (void)showAlert{ 
    [self showOnTop:NO];    
}


- (void)showOnTop:(BOOL) top{
    [self.viewAlert removeFromSuperview];
    
    UIFont *font = [UIFont systemFontOfSize:12];
	CGSize textSize = [self.message sizeWithFont:font constrainedToSize:CGSizeMake(280, 60)];
    
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width + 5, textSize.height + 5)];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.text = self.message;
	label.shadowColor = [UIColor blackColor];
	label.shadowOffset = CGSizeMake(0, 1);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    
    if (!top){
        button.frame = CGRectMake(0, 64, 320, textSize.height + 10);
    }else{
        button.frame = CGRectMake(0, 20, 320, textSize.height + 10);
    }
    
    button.alpha = 0;
    label.center = CGPointMake(button.frame.size.width / 2, button.frame.size.height / 2);
	[button addSubview:label];
	[label release];
    
    // get the windows
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
	[window addSubview:button];
    
    // set the property view
    self.viewAlert = button;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        self.viewAlert.alpha = 1;
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.3 delay:2 options:UIViewAnimationCurveEaseOut animations:^{
            self.viewAlert.alpha = 0;
        }completion:^(BOOL finished){
            [self.viewAlert removeFromSuperview];
        }];
    }];    
}


- (void)dealloc
{
    [self.viewAlert release];
    [super dealloc];
}

@end

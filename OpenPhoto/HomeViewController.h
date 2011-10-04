//
//  HomeViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 26/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebService.h"

@interface HomeViewController : UIViewController <WebServiceDelegate>{
    WebService *service;
    UIImageView *homeImageView;
}
@property (nonatomic, retain) WebService *service;
@property (nonatomic, retain) UIImageView *homeImageView;
@end

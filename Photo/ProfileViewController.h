//
//  ProfileViewController.h
//  Trovebox
//
//  Created by Patrick Santana on 05/02/13.
//  Copyright 2013 Trovebox
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
//

#import "WebService.h"
#import "OpenPhotoIASKAppSettingsViewController.h"
// image cache
#import <SDWebImage/UIImageView+WebCache.h>

//for payment
#import "SKProduct+LocalizedPrice.h"
#import "TroveboxSubscription.h"

// for clean the cache
#import "Timeline+Methods.h"
#import <SDWebImage/SDImageCache.h>

#import "GAI.h"

#import <QuartzCore/QuartzCore.h>
#import "WebViewController.h"

@interface ProfileViewController : GAITrackedViewController <UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *labelAlbums;
@property (nonatomic, weak) IBOutlet UILabel *labelPhotos;
@property (nonatomic, weak) IBOutlet UILabel *labelTags;
@property (nonatomic, weak) IBOutlet UILabel *labelStorage;
@property (nonatomic, weak) IBOutlet UILabel *labelName;
@property (nonatomic, weak) IBOutlet UIImageView *photo;
@property (nonatomic, weak) IBOutlet UILabel *labelStorageDetails;
@property (nonatomic, weak) IBOutlet UILabel *labelServer;
@property (nonatomic, weak) IBOutlet UILabel *labelAccount;
@property (nonatomic, weak) IBOutlet UILabel *labelPriceSubscription;
@property (nonatomic, weak) IBOutlet UIButton *buttonSubscription;
- (IBAction)subscribe:(id)sender;
- (IBAction)openFeaturesList:(id)sender;
@property (nonatomic, weak) IBOutlet UIButton *buttonFeatureList;


@end

//
//  FriendDetailsViewController.h
//  Trovebox
//
//  Created by Patrick Santana on 05/02/14.
//  Copyright 2014 Trovebox
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
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDImageCache.h>
#import <QuartzCore/QuartzCore.h>

@interface FriendDetailsViewController : GAITrackedViewController <UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *labelAlbums;
@property (nonatomic, weak) IBOutlet UILabel *labelPhotos;
@property (nonatomic, weak) IBOutlet UILabel *labelName;
@property (nonatomic, weak) IBOutlet UIImageView *photo;

@end

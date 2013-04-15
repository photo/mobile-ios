//
//  NewestPhotoCell.h
//  Trovebox-FIXED
//
//  Created by Patrick Santana on 27/03/12.
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

#import <MapKit/MapKit.h>
#import "SHK.h"

@interface NewestPhotoCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *photo;
@property (nonatomic, weak) IBOutlet UILabel *date;
@property (nonatomic, weak) IBOutlet UILabel *tags;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activity;
@property (nonatomic, weak) IBOutlet UIImageView *private;
@property (nonatomic, weak) IBOutlet UIButton *geoPositionButton;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) IBOutlet UIImageView *geoSharingImage;

@property (nonatomic, strong) NSString *geoPositionLatitude;
@property (nonatomic, strong) NSString *geoPositionLongitude;
@property (nonatomic, strong) NSString *photoPageUrl;
@property (nonatomic, strong) UITableViewController *newestPhotosTableViewController;

- (IBAction)openGeoPosition:(id)sender;
- (IBAction)sharePhoto:(id)sender;

@end

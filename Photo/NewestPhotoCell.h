//
//  NewestPhotoCell.h
//  OpenPhoto
//
//  Created by Patrick Santana on 27/03/12.
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
//

#import "SHK.h"

@interface NewestPhotoCell : UITableViewCell{
    NSString *geoPosition;
    NSString *photoPageUrl;
    UITableViewController *newestPhotosTableViewController;
}

@property (strong, nonatomic) IBOutlet UIImageView *photo;
@property (strong, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) IBOutlet UILabel *tags;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet UIImageView *private;
@property (strong, nonatomic) IBOutlet UIButton *geoPositionButton;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;

@property (nonatomic, copy) NSString *geoPosition;
@property (nonatomic, copy) NSString *photoPageUrl;
@property (nonatomic, strong) UITableViewController *newestPhotosTableViewController;

- (IBAction)openGeoPosition:(id)sender;
- (IBAction)sharePhoto:(id)sender;

@end

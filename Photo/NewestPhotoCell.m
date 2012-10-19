//
//  NewestPhotoCell.m
//  Photo
//
//  Created by Patrick Santana on 27/03/12.
//  Copyright 2012 Photo
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


#import "NewestPhotoCell.h"

@implementation NewestPhotoCell

@synthesize photo=_photo;
@synthesize date=_date;
@synthesize tags=_tags;
@synthesize activity=_activity;
@synthesize private=_private;
@synthesize geoPositionButton=_geoPositionButton;
@synthesize label=_label;
@synthesize shareButton = _shareButton;
@synthesize geoPosition=_geoPosition;
@synthesize photoPageUrl=_photoPageUrl;
@synthesize newestPhotosTableViewController=_newestPhotosTableViewController;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)openGeoPosition:(id)sender {
    if (self.geoPosition != nil){
        NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?q=%@",
                         [self.geoPosition stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

- (IBAction)sharePhoto:(id)sender {
    if (self.photoPageUrl != nil && self.newestPhotosTableViewController != nil){
              
        // create the item to share
        SHKItem *item = [SHKItem URL:[NSURL URLWithString:self.photoPageUrl]  title:self.label.text contentType:SHKURLContentTypeWebpage];
        

        // Get the ShareKit action sheet
        SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
        
        // ShareKit detects top view controller (the one intended to present ShareKit UI) automatically,
        // but sometimes it may not find one. To be safe, set it explicitly
       //[SHK setRootViewController:self.view];
        
        // Display the action sheet
        	[actionSheet showInView:self.newestPhotosTableViewController.viewDeckController.view];
        //[actionSheet showFromTabBar:self.newestPhotosTableViewController.tabBarController.tabBar];
    }
}
@end

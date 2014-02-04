//
//  NewestPhotoCell.m
//  Trovebox
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

@synthesize timeline=_timeline;

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
    if (self.timeline.latitude != 0){
        
        // Check for iOS 6
        Class mapItemClass = [MKMapItem class];
        if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
        {
            // Create an MKMapItem to pass to the Maps app
            CLLocationDegrees lat = [self.timeline.latitude doubleValue];
            CLLocationDegrees lon = [self.timeline.longitude doubleValue];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat,lon );
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                           addressDictionary:nil];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            [mapItem setName:NSLocalizedString(@"My Photo",@"Message to appears in the map when opened an image")];
            // Pass the map item to the Maps app
            [mapItem openInMapsWithLaunchOptions:nil];
        }else{
            NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?q=%@",
                             [[NSString stringWithFormat:@"%@,%@",self.timeline.latitude,self.timeline.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }
}

- (IBAction)sharePhoto:(id)sender {
    if (self.timeline.photoPageUrl != nil && self.newestPhotosTableViewController != nil){
        
        __block NSString *url = self.timeline.photoPageUrl;
        
        // check if photo is a private version. If it is, generate a token
        if ([self.timeline.permission boolValue] == NO){
            [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"UI Action"
                                                                                                action:@"buttonPress"
                                                                                                 label:@"Share private photo"
                                                                                                 value:nil] build]];
        }else{
            [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"UI Action"
                                                                                                action:@"buttonPress"
                                                                                                 label:@"Share public photo"
                                                                                                 value:nil] build]];
            
        }
        
        // create a dispatch to generate a token
        dispatch_queue_t token = dispatch_queue_create("generate_token_for_image", NULL);
        dispatch_async(token, ^{
            @try {
                // get's token from website
                WebService *service = [[WebService alloc] init];
                
                // set in url
                url = [service shareToken:self.timeline.key];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // stop loading
                    [MBProgressHUD hideHUDForView:self.newestPhotosTableViewController.view animated:YES];
                    
                    // share the photo
                    [self shareUrl:[NSString stringWithFormat:@"%@%@",self.timeline.photoPageUrl, url]];
                });
                
            }@catch (NSException *exception) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.newestPhotosTableViewController.view animated:YES];
                    PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:exception.description duration:5000];
                    [alert showAlert];
                });
            }
        });
        
        // show progress bar
        [MBProgressHUD showHUDAddedTo:self.newestPhotosTableViewController.view animated:YES];
    }
}

- (void) shareUrl:(NSString*) url
{
    // create the item to share
    SHKItem *item = [SHKItem URL:[NSURL URLWithString:url] title:self.label.text contentType:SHKURLContentTypeWebpage];
    
    // Get the ShareKit action sheet
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
    // ShareKit detects top view controller (the one intended to present ShareKit UI) automatically,
    // but sometimes it may not find one. To be safe, set it explicitly
    [SHK setRootViewController:self.newestPhotosTableViewController];
    
    // Display the action sheet
    [actionSheet showFromToolbar:self.newestPhotosTableViewController.navigationController.toolbar];
}

@end

//
//  NewestPhotoCell.m
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


#import "NewestPhotoCell.h"

@implementation NewestPhotoCell
@synthesize photo;
@synthesize date;
@synthesize tags;
@synthesize activity;
@synthesize private;
@synthesize geoPositionButton;
@synthesize label;
@synthesize geoPosition;

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
    
    // Configure the view for the selected state
}

- (void)dealloc {
    [label release];
    [photo release];
    [activity release];
    [date release];
    [tags release];
    [private release];
    [geoPositionButton release];
    [geoPosition release];
    [super dealloc];
}
- (IBAction)openGeoPosition:(id)sender {
    if (self.geoPosition != nil){
        NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?q=%@",
                         [self.geoPosition stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}
@end

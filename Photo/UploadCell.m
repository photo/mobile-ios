//
//  UploadCell.m
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


#import "UploadCell.h"

@implementation UploadCell
@synthesize thumb=_thumb;
@synthesize status=_status;
@synthesize btnRetry=_btnRetry;
@synthesize imageStatus = _imageStatus;
@synthesize originalObject = _originalObject;
@synthesize progressBar = _progressBar;


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

- (IBAction)refresh:(id)sender {
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Pressed refresh button");
#endif
    // change status object originalObject
    self.originalObject.status=kUploadStatusTypeCreated;
    self.progressBar.progress = 0.0;
    self.btnRetry.hidden=YES;
}

@end

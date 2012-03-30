//
//  UploadCell.h
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


#import "UploadPhotos.h"


@protocol UploadCellDelegate <NSObject>
@required
- (void) updateNeededForUploadDataSource;
@end


@interface UploadCell : UITableViewCell{
    id <UploadCellDelegate> delegate;
}

@property (retain, nonatomic) IBOutlet UIImageView *thumb;
@property (retain, nonatomic) IBOutlet UILabel *status;
@property (retain, nonatomic) IBOutlet UIButton *btnRetry;
@property (retain, nonatomic) IBOutlet UIButton *btnCancel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (retain, nonatomic) UploadPhotos *originalObject;

// protocol that will send the response
@property (retain) id delegate;

- (IBAction)refresh:(id)sender;
- (IBAction)cancel:(id)sender;

@end

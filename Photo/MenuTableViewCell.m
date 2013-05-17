//
//  MenuTableViewCell.m
//  Trovebox
//
//  Created by Patrick Santana on 07/03/13.
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

#import "MenuTableViewCell.h"

@implementation MenuTableViewCell
@synthesize label=_label,imageDefault=_imageDefault,imageSelected=_imageSelected,imageLine=_imageLine;

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
    
    if (selected){
        self.label.textColor = UIColorFromRGB(0xFECD31);
        // change the image to selected one
        [self.image setImage:[UIImage imageNamed:self.imageSelected]];
        // change the narrow in the left
        self.imageLine.hidden = FALSE;
    }else{
        self.label.textColor = [UIColor whiteColor];
        // change the image to the default
        [self.image setImage:[UIImage imageNamed:self.imageDefault]];
        
        // change the narrow in the left
          self.imageLine.hidden = TRUE;
    }
}

@end

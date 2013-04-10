//
//  MenuTableViewSectionCell.m
//  Trovebox
//
//  Created by Patrick Santana on 07/03/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "MenuTableViewSectionCell.h"

@implementation MenuTableViewSectionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.labelPreferences.text = NSLocalizedString(@"PREFERENCES",@"Content of the menu for the PREFERENCES");
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  MenuTableViewSearchCell.m
//  Trovebox
//
//  Created by Patrick Santana on 07/03/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "MenuTableViewSearchCell.h"

@implementation MenuTableViewSearchCell

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

// Action if user clicks in DONE in the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // return
    [textField resignFirstResponder];
    return YES;
}

@end

//
//  MenuTableViewCell.h
//  Trovebox
//
//  Created by Patrick Santana on 07/03/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTableViewCell : UITableViewCell


// image
@property (strong, nonatomic) NSString *imageDefault;
// image when selected
@property (strong, nonatomic) NSString *imageSelected;


@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageLine;

@end

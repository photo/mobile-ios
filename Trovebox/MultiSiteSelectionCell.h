//
//  MultiSiteSelectionCell.h
//  Trovebox
//
//  Created by Patrick Santana on 18/10/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultiSiteSelectionCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *type;
@property (strong, nonatomic) IBOutlet UILabel *host;
@property (strong, nonatomic) IBOutlet UIImageView *userImage;

@end

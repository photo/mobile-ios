//
//  FriendsCell.h
//  Trovebox
//
//  Created by Patrick Santana on 30/04/14.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *host;
@property (strong, nonatomic) IBOutlet UIImageView *userImage;

@end

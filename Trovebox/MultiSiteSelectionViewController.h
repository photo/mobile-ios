//
//  MultiSiteSelectionViewController.h
//  Trovebox
//
//  Created by Patrick Santana on 15/10/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"
#import "MultiSiteSelectionCell.h"

// image cache
#import <SDWebImage/UIImageView+WebCache.h>

@interface MultiSiteSelectionViewController : UITableViewController

-(id) initWithAccounts:(NSArray*) accounts;

@end

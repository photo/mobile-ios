//
//  SyncViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 05/05/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "SyncViewController.h"

@interface SyncViewController ()

@end

@implementation SyncViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"BackgroundUpload.png"]];
        
        // color separator
        self.tableView.separatorColor = UIColorFromRGB(0xC8BEA0);

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];   
    // set the tile of the table
    self.title=@"Sync"; 
}


@end
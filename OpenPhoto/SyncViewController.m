//
//  SyncViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 05/05/12.
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
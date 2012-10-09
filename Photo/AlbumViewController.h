//
//  AlbumViewController.h
//  Photo
//
//  Created by Patrick Santana on 09/10/12.
//  Copyright (c) 2012 Photo Project. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"

@interface AlbumViewController : UITableViewController<UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray *albums;

@end

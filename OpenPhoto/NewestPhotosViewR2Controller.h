//
//  NewestPhotosViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 20/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//
#import "EGORefreshTableHeaderView.h"

@interface NewestPhotosViewR2Controller : UITableViewController  <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource>{
	
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    //  Reloading var should really be your tableviews datasource
    //  Putting it here for demo purposes 
    BOOL _reloading;
    NSArray *newestPhotos;
    NSArray *uploads;
}

@property (nonatomic, retain) NSArray *newestPhotos;
@property (nonatomic, retain) NSArray *uploads;    

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
@end


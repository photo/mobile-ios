//
//  ActivityFeedViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 20/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "EGORefreshTableHeaderView.h"

@interface ActivityFeedViewController : UITableViewController <EGORefreshTableHeaderDelegate, UITableViewDataSource, UITableViewDelegate>{
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    //  Reloading var should really be your tableviews datasource
    //  Putting it here for demo purposes 
    BOOL _reloading;
}


- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
@end


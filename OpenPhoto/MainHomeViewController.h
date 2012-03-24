//
//  MainHomeViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 22/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "NewestPhotosViewController.h"
#import "ActivityFeedViewController.h"


@interface MainHomeViewController : UIViewController{
    NewestPhotosViewController *newestPhotosViewController;
    ActivityFeedViewController *activityFeedViewController;
}

@property (nonatomic,retain,readonly) NewestPhotosViewController *newestPhotosViewController;
@property (nonatomic,retain,readonly)  ActivityFeedViewController *activityFeedViewController;

@property (retain, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (retain, nonatomic) IBOutlet UIView *currentImageView;

@end

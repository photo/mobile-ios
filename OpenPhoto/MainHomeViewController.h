//
//  MainHomeViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 22/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "NewestPhotosViewR2Controller.h"
#import "ActivityFeedViewController.h"


@interface MainHomeViewController : UIViewController{
    NewestPhotosViewR2Controller *newestPhotosViewController;
    ActivityFeedViewController *activityFeedViewController;
}

@property (nonatomic,retain,readonly) NewestPhotosViewR2Controller *newestPhotosViewController;
@property (nonatomic,retain,readonly)  ActivityFeedViewController *activityFeedViewController;

@property (retain, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (retain, nonatomic) IBOutlet UIView *currentImageView;

@end

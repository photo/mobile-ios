//
//  MainHomeViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 22/03/12.
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
//

#import "NewestPhotosTableViewController.h"
#import "ActivityFeedViewController.h"


@interface MainHomeViewController : UIViewController{
    NewestPhotosTableViewController *newestPhotosViewController;
    ActivityFeedViewController *activityFeedViewController;
}

@property (nonatomic,retain,readonly) NewestPhotosTableViewController *newestPhotosViewController;
@property (nonatomic,retain,readonly)  ActivityFeedViewController *activityFeedViewController;

@property (retain, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (retain, nonatomic) IBOutlet UIView *currentImageView;

@end

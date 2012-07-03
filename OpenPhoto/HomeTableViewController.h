//
//  HomeTableViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 22/06/12.
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

#import "EGORefreshTableHeaderView.h"
#import "TimelinePhotos+OpenPhoto.h"
#import "OpenPhotoServiceFactory.h"

#import "NewestPhotoCell.h"
#import "UploadCell.h"

#import "CoreLocationController.h"
#import "CoreDataTableViewController.h"
#import "SHA1.h"

@interface HomeTableViewController : CoreDataTableViewController<EGORefreshTableHeaderDelegate>{
 
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    //  Reloading var should really be your tableviews datasource
    //  Putting it here for demo purposes 
    BOOL _reloading;
    
    UIImageView *noPhotoImageView;
    
    // ask the user about location int the home screen
    CoreLocationController *coreLocationController;
}

@property (nonatomic, retain) UIImageView *noPhotoImageView;

@end

//
//  HomeTableViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 22/06/12.
//  Copyright 2013 Trovebox
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

#import "HomeTableViewController.h"

@interface HomeTableViewController ()
// refresh the list. It is not necessary when comes from photo
@property (nonatomic) BOOL needsUpdate;
@property (nonatomic, strong) MWPhoto* mwphoto;

- (void) doneLoadingTableViewData;
- (void) updateProfileDetails;
- (void) updateServerDetails;
@end

@implementation HomeTableViewController
@synthesize noPhotoImageView=_noPhotoImageView;
@synthesize needsUpdate = _needsUpdate;
@synthesize mwphoto=_mwphoto;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        CGPoint imageSize = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
        self.noPhotoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home-upload-now.png"]];
        self.noPhotoImageView.center = imageSize;
        self.noPhotoImageView.hidden = YES;
        
        coreLocationController = [[CoreLocationController alloc] init];
        
        // nothing is loading
        _reloading = NO;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Timeline" inManagedObjectContext:[SharedAppDelegate managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        
        fetchRequest.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"photoToUpload" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"dateUploaded" ascending:NO],nil];
        
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                     managedObjectContext:[SharedAppDelegate managedObjectContext]
                                                                                       sectionNameKeyPath:nil
                                                                                                cacheName:nil];
        self.fetchedResultsController =  controller;
        
        
        // needs update in screen
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(eventHandler:)
                                                     name:kNotificationNeededsUpdateHome
                                                   object:nil ];
        
        // set that it always need update
        self.needsUpdate = YES;
        // if we don't need update, it needs to receive a notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(eventHandler:)
                                                     name:kNotificationDisableUpdateHome
                                                   object:nil ];
        
        // update profile information
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(eventHandler:)
                                                     name:kNotificationProfileRefresh
                                                   object:nil ];
        
        
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([AuthenticationService isLogged]){
        if (self.needsUpdate == YES){
            [self loadNewestPhotosIntoCoreData];
        }else{
            // next time it can be reloaded
            self.needsUpdate = YES;
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
#ifdef GOOGLE_ANALYTICS_ENABLED
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Screens"
                                                      withAction:@"Loaded"
                                                       withLabel:@"Home"
                                                       withValue:nil];
#endif
    
    // ask if user wants to enable location
    [coreLocationController.locMgr startUpdatingLocation];
    [coreLocationController.locMgr stopUpdatingLocation];
    
    // if no picture, show image to upload
    if ([[self.fetchedResultsController fetchedObjects] count]== 0){
        [self.view addSubview:self.noPhotoImageView];
        self.noPhotoImageView.hidden = NO;
    }else{
        [self.noPhotoImageView removeFromSuperview];
    }
    
    // details screen
    self.view.backgroundColor =  UIColorFromRGB(0XFAF3EF);
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // check if needs to update the profile
    [self needsUpdateProfileDetails];
    
    // select the first row in the menu
    [(MenuViewController*) SharedAppDelegate.menuController selectLatestActivity];
    
    // items and text
    [self.navigationItem troveboxStyle:@"" defaultButtons:YES viewController:self.viewDeckController menuViewController:(MenuViewController*) self.viewDeckController.leftController];
    
    // image for the navigator
    [self.navigationController.navigationBar troveboxStyle:YES];
    
    // update server details
    [self updateServerDetails];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = UIColorFromRGB(0x3B2414);
    self.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(changeSorting) forControlEvents:UIControlEventValueChanged];
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *photoCellIdentifier = @"photoCell";
    static NSString *uploadCellIdentifier = @"uploadCell";
    
    // get the object
    Timeline *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    // first decide if we have to show a upload cell or photo cell
    if (![photo.status isEqualToString:kUploadStatusTypeUploaded]){
        // in this case, we have uploads and the cell must be a upload cell
        UploadCell *uploadCell= (UploadCell *)[tableView dequeueReusableCellWithIdentifier:uploadCellIdentifier];
        
        if (uploadCell == nil) {
            NSString *cellNibName;
            if ([DisplayUtilities isIPad]){
                cellNibName=@"UploadCelliPad";
            }else{
                cellNibName=@"UploadCell";
            }
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellNibName owner:nil options:nil];
            uploadCell = [topLevelObjects objectAtIndex:0];
            if([[UITabBar class] respondsToSelector:@selector(appearance)]){
                // from iOS 5.0
                uploadCell.progressBar.progressTintColor = UIColorFromRGB(0xFECD31);
                uploadCell.progressBar.trackTintColor = UIColorFromRGB(0x3B2414);
            }
        }
        
        // set the upload photo object in the cell for restart or cancel
        uploadCell.originalObject = photo;
        
        // set thumb
        uploadCell.thumb.image = [UIImage imageWithData:photo.photoDataThumb];
        [uploadCell.thumb.superview.layer setCornerRadius:3.0f];
        [uploadCell.thumb.superview.layer setShadowColor:[UIColor blackColor].CGColor];
        [uploadCell.thumb.superview.layer setShadowOpacity:0.25];
        [uploadCell.thumb.superview.layer setShadowRadius:1.0];
        [uploadCell.thumb.superview.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
        
        // set status and image upload status
        uploadCell.imageStatus.hidden=YES;
        uploadCell.progressBar.hidden=YES;
        
        if ( [photo.status isEqualToString:kUploadStatusTypeCreated]){
            uploadCell.status.text=NSLocalizedString(@"Waiting ...",@"Status upload - waiting");
            [uploadCell.imageStatus setImage:[UIImage imageNamed:@"home-waiting.png"]];
            uploadCell.imageStatus.hidden=NO;
            uploadCell.status.textColor=UIColorFromRGB(0x3B2414);
        }else if ( [photo.status isEqualToString:kUploadStatusTypeUploading]){
            uploadCell.status.text=@"";
            uploadCell.status.textColor=UIColorFromRGB(0x3B2414);
            uploadCell.progressBar.hidden=NO;
            
            [uploadCell.progressBar setProgress:[photo.photoUploadProgress floatValue]];
        }else if ( [photo.status isEqualToString:kUploadStatusTypeUploadFinished]){
            uploadCell.status.text=NSLocalizedString(@"Upload finished!",@"Status upload - Upload finished!");
            uploadCell.status.textColor=UIColorFromRGB(0x3B2414);
            [uploadCell.imageStatus setImage:[UIImage imageNamed:@"home-finished.png"]];
            uploadCell.imageStatus.hidden=NO;
            uploadCell.status.textColor=UIColorFromRGB(0x3B2414);
            
            // check if it needs share for twitter or facebook
            // prepare NSDictionary with details of sharing if Twitter or Facebook was checked
            if ([photo.twitter boolValue] ||  [photo.facebook boolValue]){
#ifdef DEVELOPMENT_ENABLED
                NSLog(@"User wants to share uploaded photo");
#endif
                
                NSDictionary *responsePhoto = [NSDictionarySerializer nsDataToNSDictionary:photo.photoUploadResponse];
                
                // parameters from upload
                NSArray *keys = [NSArray arrayWithObjects:@"url", @"title",@"type",nil];
                NSString *shareDetails = [responsePhoto objectForKey:@"url"];
                if (photo.photoUploadMultiplesUrl){
                    shareDetails = photo.photoUploadMultiplesUrl;
                }
                NSArray *objects= [NSArray arrayWithObjects: shareDetails, [NSString stringWithFormat:@"%@", [responsePhoto objectForKey:@"title"]],[photo.twitter boolValue] ? @"Twitter" : @"Facebook", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShareInformationToFacebookOrTwitter object:[NSDictionary dictionaryWithObjects:objects forKeys:keys] ];
            }
            
            // delete this object after 2 seconds
            [self performSelector:@selector(deleteTimeline:) withObject:photo afterDelay:2.0];
        }else if ( [photo.status isEqualToString:kUploadStatusTypeFailed]){
            uploadCell.status.text=NSLocalizedString(@"Retry uploading",@"Status upload - Retry uploading!");
            uploadCell.status.textColor=UIColorFromRGB(0x3B2414);
        }else if ( [photo.status isEqualToString:kUploadStatusTypeDuplicated]){
            uploadCell.status.text=NSLocalizedString(@"Already in your account",@"Status upload - Already in your account");
            [uploadCell.imageStatus setImage:[UIImage imageNamed:@"home-already-uploaded.png"]];
            uploadCell.imageStatus.hidden=NO;
            uploadCell.status.textColor=UIColorFromRGB(0x3B2414);
            
            // delete this object after 2 seconds
            [self performSelector:@selector(deleteTimeline:) withObject:photo afterDelay:2.0];
        }else if ( [photo.status isEqualToString:kUploadStatusTypeLimitReached]){
            uploadCell.status.text=NSLocalizedString(@"Limit reached",@"Status upload - Limit reached!");
            uploadCell.status.textColor=UIColorFromRGB(0x3B2414);
        }else if ( [photo.status isEqualToString:kUploadStatusTypeCreating]){
            uploadCell.status.text=NSLocalizedString(@"Creating ...",@"Status upload - Creating ...");
            [uploadCell.imageStatus setImage:[UIImage imageNamed:@"home-waiting.png"]];
            uploadCell.imageStatus.hidden=NO;
            uploadCell.status.textColor=UIColorFromRGB(0x3B2414);
        }else{
            // it is invalid
            uploadCell.status.text=NSLocalizedString(@"Invalid photo",@"Status upload - Invalid photo!");
            [uploadCell.imageStatus setImage:[UIImage imageNamed:@"home-already-uploaded.png"]];
            uploadCell.imageStatus.hidden=NO;
            uploadCell.status.textColor=UIColorFromRGB(0x3B2414);
            
            // delete this object after 1 seconds
            [self performSelector:@selector(deleteTimeline:) withObject:photo afterDelay:1.0];
            
        }
        
        // decide if we show retry/cancel
        if ([photo.status isEqualToString:kUploadStatusTypeFailed] ||
            [photo.status isEqualToString:kUploadStatusTypeLimitReached]) {
            uploadCell.btnRetry.hidden  = NO;
        }else{
            uploadCell.btnRetry.hidden  = YES;
        }
        
        return uploadCell;
    }else{
        
        NewestPhotoCell *newestPhotoCell = (NewestPhotoCell *)[tableView dequeueReusableCellWithIdentifier:photoCellIdentifier];
        
        if (newestPhotoCell == nil) {
            NSString *cellNibName;
            if ([DisplayUtilities isIPad]){
                cellNibName=@"NewestPhotoCelliPad";
            }else{
                cellNibName=@"NewestPhotoCell";
            }
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellNibName owner:nil options:nil];
            newestPhotoCell = [topLevelObjects objectAtIndex:0];
            
            // change the color if it is allowed
            if( [[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0){
                newestPhotoCell.activity.color=UIColorFromRGB(0x3B2414);
            }
        }
        
        
        // title
        [newestPhotoCell label].text=photo.title;
        
        // days or hours
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:photo.date];
        
        NSInteger days = interval/86400;
        if (days >= 2 ){
            if (days > 365){
                // show in years
                if (days/365 == 1){
                    [newestPhotoCell date].text = NSLocalizedString(@"This photo was taken one year ago",@"Message for photo details in the home - This photo was taken one year ago");
                }else{
                    [newestPhotoCell date].text = [NSString stringWithFormat:NSLocalizedString(@"This photo was taken %i years ago",@"Message for photo details in the home - This photo was taken %i years ago"), days/365];
                }
            }else{
                // lets show in days
                [newestPhotoCell date].text = [NSString stringWithFormat:NSLocalizedString(@"This photo was taken %i days ago",@"Message for photo details in the home - This photo was taken %i days ago"), days];
            }
        }else{
            // lets show in hours
            NSInteger hours = interval / 3600;
            if (hours<1){
                [newestPhotoCell date].text = NSLocalizedString(@"This photo was taken less than one hour ago",@"Message for photo details in the home - less than one hour ago");
            }else {
                if (hours == 1){
                    [newestPhotoCell date].text = NSLocalizedString(@"This photo was taken one hour ago",@"Message for photo details in the home - This photo was taken one hour ago");
                }else {
                    [newestPhotoCell date].text = [NSString stringWithFormat:NSLocalizedString(@"This photo was taken %i hours ago",@"Message for photo details in the home - This photo was taken %i hours ago"), hours];
                }
            }
        }
        
        // tags
        [newestPhotoCell tags].text=photo.tags;
        newestPhotoCell.private.hidden=YES;
        newestPhotoCell.shareButton.hidden=YES;
        newestPhotoCell.geoPositionButton.hidden=YES;
        newestPhotoCell.geoSharingImage.hidden=YES;
        [newestPhotoCell.activity startAnimating];
        
        [newestPhotoCell.photo setImageWithURL:[NSURL URLWithString:photo.photoUrl]
                              placeholderImage:nil
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                                         if (error){
                                             PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Couldn't download the image",nil) duration:5000];
                                             [alert showAlert];
                                             NSLog(@"Error: %@",[error localizedDescription]);
                                             
                                             [[SharedAppDelegate managedObjectContext] deleteObject:photo];
                                         }else{
                                             [newestPhotoCell.activity stopAnimating];
                                             newestPhotoCell.photo.superview.layer.masksToBounds = NO;
                                             [newestPhotoCell.photo.superview.layer setShadowColor:[UIColor blackColor].CGColor];
                                             [newestPhotoCell.photo.superview.layer setShadowOpacity:0.25];
                                             [newestPhotoCell.photo.superview.layer setShadowRadius:1.0];
                                             [newestPhotoCell.photo.superview.layer setShadowOffset:CGSizeMake(2.0, 0.0)];
                                             [newestPhotoCell.photo.superview.layer setShadowPath:[UIBezierPath bezierPathWithRect:[newestPhotoCell.photo.superview.layer bounds]].CGPath];
                                             
                                             
                                             // set objects
                                             newestPhotoCell.timeline = photo;
                                             newestPhotoCell.newestPhotosTableViewController = self;
                                             
                                             // set details of private or not
                                             if ([photo.permission boolValue] == NO){
                                                 newestPhotoCell.private.hidden=NO;
                                             }
                                             
                                             // user can share
                                             if (photo.photoUrl != nil){
                                                 newestPhotoCell.shareButton.hidden=NO;
                                             }
                                             
                                             // set details geoposition
                                             newestPhotoCell.geoSharingImage.hidden=NO;
                                             if (photo.latitude != nil && photo.longitude != nil){
                                                 // show button
                                                 newestPhotoCell.geoPositionButton.hidden=NO;
                                                 newestPhotoCell.geoSharingImage.image = [UIImage imageNamed:@"home-geo-on-sharing.png"];
                                             }else {
                                                 newestPhotoCell.geoPositionButton.hidden=YES;
                                                 newestPhotoCell.geoSharingImage.image = [UIImage imageNamed:@"home-geo-off-sharing.png"];
                                             }
                                         }
                                     }];
        
        return newestPhotoCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Timeline *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([photo.status isEqualToString:kUploadStatusTypeUploaded]){
        if ([DisplayUtilities isIPad])
            return 600;
        else
            return 365;
    }else{
        return 44;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Timeline *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([photo.status isEqualToString:kUploadStatusTypeUploaded]){
        
        // Create & present browser
        self.mwphoto = [MWPhoto photoWithURL:[NSURL URLWithString:photo.photoUrlDetail]];
        
        // set details
        self.mwphoto.identification = photo.key;
        self.mwphoto.pageUrl = photo.photoPageUrl;
        self.mwphoto.permission = photo.permission;
        
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        // Set options
        // browser.wantsFullScreenLayout = YES;
        browser.displayActionButton = YES;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:browser];
        
        // Present
        [self presentViewController:nav animated:NO completion:nil];
    }
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return self.mwphoto;
}


// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // get the object
    Timeline *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    // first decide if we have to show a upload cell or photo cell
    if ([photo.status isEqualToString:kUploadStatusTypeFailed]){
        return YES;
    }
    
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Pressed delete button");
#endif
        // delete object originalObject
        Timeline *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //delete the file
        NSError *error = nil;
        if ([[NSFileManager defaultManager] removeItemAtPath:photo.photoDataTempUrl error:&error] != YES)
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        
        [[SharedAppDelegate managedObjectContext] deleteObject:photo];
    }
}

- (void) deleteTimeline:(Timeline *) photo
{
    [[SharedAppDelegate managedObjectContext] deleteObject:photo];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)doneLoadingTableViewData
{
    _reloading = NO;
    [self.refreshControl endRefreshing];
    
    // if no picture, show image to upload
    if ([[self.fetchedResultsController fetchedObjects] count]== 0){
        [self.navigationController.view addSubview:self.noPhotoImageView];
        self.noPhotoImageView.hidden = NO;
    }else{
        [self.noPhotoImageView removeFromSuperview];
    }
}

#pragma mark -
#pragma mark Refresh Methods

- (void)changeSorting
{
 [self loadNewestPhotosIntoCoreData];
}

#pragma mark -
#pragma mark Population core data
- (void) loadNewestPhotosIntoCoreData
{
    if (_reloading == NO && [AuthenticationService isLogged]){
        // set reloading in the table
        _reloading = YES;
        
        // if there isn't netwok
        if ( [SharedAppDelegate internetActive] == NO ){
            [self notifyUserNoInternet];
            [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
        }else {
            dispatch_queue_t loadNewestPhotos = dispatch_queue_create("loadNewestPhotos", NULL);
            dispatch_async(loadNewestPhotos, ^{
                // call the method and get the details
                @try {
                    // get factory for OpenPhoto Service
                    WebService *service = [[WebService alloc] init];
                    NSArray *result = [service fetchNewestPhotosMaxResult:25];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // let NewestPhotos treat the objects
                        [Timeline insertIntoCoreData:result InManagedObjectContext:[SharedAppDelegate managedObjectContext]];
                        [self doneLoadingTableViewData];
                    });
                }@catch (NSException *exception) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Failed! We couldn't get your newest photos.",@"Message in the home when trying to load newest photos") duration:5000];
                        [alert showAlert];
                        
                        // refresh table
                        [self doneLoadingTableViewData];
                    });
                }
            });
        }
    }
}

- (void) notifyUserNoInternet{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // problem with internet, show message to user
    PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Please check your internet connection",@"") duration:5000];
    [alert showAlert];
}

- (void) eventHandler: (NSNotification *) notification{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"###### Event triggered: %@", notification);
#endif
    
    if ([notification.name isEqualToString:kNotificationNeededsUpdateHome]){
        [self loadNewestPhotosIntoCoreData];
    }else if ([notification.name isEqualToString:kNotificationDisableUpdateHome]){
        self.needsUpdate = NO;
    }else if ([notification.name isEqualToString:kNotificationProfileRefresh]){
        [self updateProfileDetails];
    }
}

- (void) needsUpdateProfileDetails
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Checking if needs update profile");
#endif
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    // is there a variable for the latest update profile information
    if ([standardUserDefaults objectForKey:kProfileLatestUpdateDate] != nil){
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Variable exists, do the check");
#endif
        if ([DateUtilities daysBetween:[standardUserDefaults objectForKey:kProfileLatestUpdateDate] and:[NSDate date]] > 1){
            // update it sending a notification
            [self updateProfileDetails];
        }
    }else{
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Variable does not exist, create for the first time");
#endif
        // it does not exist, creates it invoking the method to refresh
        [self updateProfileDetails];
    }
}

- (void) updateServerDetails
{
    if ( [SharedAppDelegate internetActive] == YES && [AuthenticationService isLogged]){
        dispatch_queue_t get_server_details = dispatch_queue_create("get_server_details", NULL);
        dispatch_async(get_server_details, ^{
            
            @try{
                WebService *service = [[WebService alloc] init];
                NSDictionary *rawAnswer = [service getSystemVersion];
                NSDictionary *result = [rawAnswer objectForKey:@"result"];
                
                // display details
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([result class] != [NSNull class]) {
                        // save details locally
                        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                        [standardUserDefaults setValue:result forKey:kServerDetails];
                        
                        if ([result objectForKey:@"isHosted"] == nil){
                            [standardUserDefaults setValue:NO forKey:kServerDetailsIsHosted];
                        }else{
                            [standardUserDefaults setValue:[result objectForKey:@"isHosted"] forKey:kServerDetailsIsHosted];
                        }
                        [standardUserDefaults synchronize];
                    }
                });
            }@catch (NSException* e) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Could not load server details: %@",[e description]);
                });
            }
        });
    }
}

- (void) updateProfileDetails
{
    if ( [SharedAppDelegate internetActive] == YES && [AuthenticationService isLogged]){
        dispatch_queue_t get_user_details = dispatch_queue_create("get_user_details", NULL);
        dispatch_async(get_user_details, ^{
            
            @try{
                WebService *service = [[WebService alloc] init];
                NSDictionary *rawAnswer = [service getUserDetails];
                NSDictionary *result = [rawAnswer objectForKey:@"result"];
                
                // display details
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([result class] != [NSNull class]) {
                        // limits
                        NSDictionary* limits = [result objectForKey:@"limit"];
                        
                        // save details locally
                        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                        [standardUserDefaults setValue:[result objectForKey:@"name"] forKey:kTroveboxNameUser];
                        [standardUserDefaults setValue:[result objectForKey:@"email"] forKey:kTroveboxEmailUser];
                        [standardUserDefaults setValue:[NSDate date] forKey:kProfileLatestUpdateDate];
                        [standardUserDefaults setValue:[result objectForKey:@"paid"] forKey:kProfileAccountType];
                        [standardUserDefaults setValue:[limits objectForKey:@"remaining"] forKey:kProfileLimitRemaining];
                        [standardUserDefaults setValue:[limits objectForKey:@"allowed"] forKey:kProfileLimitAllowed];
                        
                        [standardUserDefaults synchronize];
                    }
                });
            }@catch (NSException* e) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Could not update the probile: %@",[e description]);
                });
            }
        });
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
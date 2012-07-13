//
//  HomeTableViewController.m
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

#import "HomeTableViewController.h"

@interface HomeTableViewController ()
// refresh the list. It is not necessary when comes from photo
@property (nonatomic) BOOL needsUpdate;

- (void)doneLoadingTableViewData;
@end

@implementation HomeTableViewController
@synthesize noPhotoImageView=_noPhotoImageView;
@synthesize needsUpdate = _needsUpdate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // transparent background
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.opaque = NO;
        self.tableView.backgroundView = nil;
        
        self.tabBarItem.title=@"Home";
        self.title=@"";
        
        UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Background.png"]];
        self.view.backgroundColor = background;
        [background release];
        
        self.tableView.separatorColor = UIColorFromRGB(0xC8BEA0);
        
        CGRect imageSize = CGRectMake(0, 63, 320, 367);
        self.noPhotoImageView = [[UIImageView alloc] initWithFrame:imageSize];
        self.noPhotoImageView.image = [UIImage imageNamed:@"home-upload-now.png"];
        self.noPhotoImageView.hidden = YES;
        
        coreLocationController = [[CoreLocationController alloc] init];
        
        // nothing is loading
        _reloading = NO;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TimelinePhotos" inManagedObjectContext:[AppDelegate managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        
        fetchRequest.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"photoToUpload" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"dateUploaded" ascending:NO],nil];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:[AppDelegate managedObjectContext]
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
        
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
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];   
    
    if (self.needsUpdate == YES){
        [self loadNewestPhotosIntoCoreData];
    }else{
        // next time it can be reloaded
        self.needsUpdate = YES;
    }
#ifdef TEST_FLIGHT_ENABLED
    [TestFlight passCheckpoint:@"Newest Photos Loaded"];
#endif
    
    // ask if user wants to enable location
    [coreLocationController.locMgr startUpdatingLocation];    
    [coreLocationController.locMgr stopUpdatingLocation];  
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height) arrowImageName:@"home-brown-arrow.png" textColor:UIColorFromRGB(0x645840)];
		view.delegate = self;
        
        // set background
        view.backgroundColor = [UIColor clearColor];
        view.opaque = NO;
        
        
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
    
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
}


#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {   
    static NSString *photoCellIdentifier = @"photoCell";
    static NSString *uploadCellIdentifier = @"uploadCell";
    
    // get the object
    TimelinePhotos *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    // first decide if we have to show a upload cell or photo cell
    if (![photo.status isEqualToString:kUploadStatusTypeUploaded]){
        // in this case, we have uploads and the cell must be a upload cell
        UploadCell *uploadCell= (UploadCell *)[tableView dequeueReusableCellWithIdentifier:uploadCellIdentifier];
        
        if (uploadCell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UploadCell" owner:nil options:nil];
            uploadCell = [topLevelObjects objectAtIndex:0];
            if([[UITabBar class] respondsToSelector:@selector(appearance)]){
                // from iOS 5.0
                uploadCell.progressBar.progressTintColor = UIColorFromRGB(0xE6501E);
                uploadCell.progressBar.trackTintColor = UIColorFromRGB(0xC8BEA0);
            }
        }
        
        
        
        // set the upload photo object in the cell for restart or cancel
        uploadCell.originalObject = photo;
        
        // set thumb
        CGSize itemSize = CGSizeMake(70, 70);
        UIGraphicsBeginImageContext(itemSize);
        
        UIImage *image =  [UIImage imageWithData:photo.photoData];
        [image drawInRect:CGRectMake(0, 0, 70, 70)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData* imageData1 =[NSData dataWithData:UIImagePNGRepresentation (image)]; 
        uploadCell.thumb.image = [UIImage imageWithData:imageData1];   
        [uploadCell.thumb.superview.layer setCornerRadius:3.0f];
        [uploadCell.thumb.superview.layer setShadowColor:[UIColor blackColor].CGColor];
        [uploadCell.thumb.superview.layer setShadowOpacity:0.25];
        [uploadCell.thumb.superview.layer setShadowRadius:1.0];
        [uploadCell.thumb.superview.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
        
        // set status and image upload status
        uploadCell.imageStatus.hidden=YES;
        uploadCell.progressBar.hidden=YES;
        
        if ( [photo.status isEqualToString:kUploadStatusTypeCreated]){
            uploadCell.status.text=@"Waiting ...";
            [uploadCell.imageStatus setImage:[UIImage imageNamed:@"home-waiting.png"]];
            uploadCell.imageStatus.hidden=NO;
            uploadCell.status.textColor=UIColorFromRGB(0xE6501E);
        }else if ( [photo.status isEqualToString:kUploadStatusTypeUploading]){
            uploadCell.status.text=@"";
            uploadCell.status.textColor=UIColorFromRGB(0xE6501E);
            uploadCell.progressBar.hidden=NO;
            
            [uploadCell.progressBar setProgress:[photo.photoUploadProgress floatValue]];
        }else if ( [photo.status isEqualToString:kUploadStatusTypeUploadFinished]){
            uploadCell.status.text=@"Upload finished!";
            uploadCell.status.textColor=UIColorFromRGB(0xE6501E);
            [uploadCell.imageStatus setImage:[UIImage imageNamed:@"home-finished.png"]];
            uploadCell.imageStatus.hidden=NO;
            uploadCell.status.textColor=UIColorFromRGB(0xE6501E);
            
            // check if it needs share for twitter or facebook
            // prepare NSDictionary with details of sharing if Twitter or Facebook was checked
            if ([photo.twitter boolValue] ||  [photo.facebook boolValue]){
#ifdef DEVELOPMENT_ENABLED
                NSLog(@"User wants to share uploaded photo");
#endif
#ifdef TEST_FLIGHT_ENABLED
                if ([photo.twitter boolValue]){
                    [TestFlight passCheckpoint:@"Twitter"];
                }else{
                    // facebook
                    [TestFlight passCheckpoint:@"Facebook"];
                }
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
            uploadCell.status.text=@"Retry uploading";
            uploadCell.status.textColor=UIColorFromRGB(0xE6501E);
        }else if ( [photo.status isEqualToString:kUploadStatusTypeDuplicated]){
            uploadCell.status.text=@"Already in your account";
            [uploadCell.imageStatus setImage:[UIImage imageNamed:@"home-already-uploaded.png"]];
            uploadCell.imageStatus.hidden=NO;
            uploadCell.status.textColor=UIColorFromRGB(0xC8BEA0);
            
            // delete this object after 2 seconds
            [self performSelector:@selector(deleteTimeline:) withObject:photo afterDelay:2.0];
        }
        
        // decide if we show retry/cancel
        if (![photo.status isEqualToString:kUploadStatusTypeFailed]) {
            uploadCell.btnRetry.hidden  = YES;
        }else{
            uploadCell.btnRetry.hidden  = NO;
        }
        
        return uploadCell;
    }else{
        
        NewestPhotoCell *newestPhotoCell = (NewestPhotoCell *)[tableView dequeueReusableCellWithIdentifier:photoCellIdentifier];
        
        if (newestPhotoCell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NewestPhotoCell" owner:nil options:nil];
            newestPhotoCell = [topLevelObjects objectAtIndex:0];
            
            // change the color if it is allowed
            if( [[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0){
                newestPhotoCell.activity.color=UIColorFromRGB(0xE6501E);
            }
        }
        
        
        // title
        [newestPhotoCell label].text=photo.title;
        
        // days or hours
        NSMutableString *dateText = [[NSMutableString alloc]initWithString:@"This photo was taken "];
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:photo.date];
        
        NSInteger days = interval/86400;
        if (days >= 2 ){
            if (days > 365){
                // show in years 
                [dateText appendFormat:days/365 == 1 ? [NSString stringWithFormat:@"%i year ago",days/365] : [NSString stringWithFormat:@"%i years ago",days/365]];
            }else{
                // lets show in days
                [dateText appendFormat:@"%i days ago",days];
            }
            
        }else{
            // lets show in hours
            NSInteger hours = interval / 3600;
            if (hours<1){
                [dateText appendString:@"less than one hour ago"];
            }else {
                if (hours == 1){
                    [dateText appendString:@"one hour ago"];
                }else {
                    [dateText appendFormat:@"%i hours ago",hours];
                }
            }
        }
        
        [newestPhotoCell date].text=dateText;
        [dateText release];
        
        // tags
        [newestPhotoCell tags].text=photo.tags;
        newestPhotoCell.private.hidden=YES;
        newestPhotoCell.shareButton.hidden=YES;
        newestPhotoCell.geoPositionButton.hidden=YES;
        
        [newestPhotoCell.photo setImageWithURL:[NSURL URLWithString:photo.photoUrl]
                              placeholderImage:nil 
                                       success:^(UIImage *image) 
         {
             [newestPhotoCell.photo.layer setCornerRadius:5.0f];
             newestPhotoCell.photo.layer.masksToBounds = YES;
             
             [newestPhotoCell.photo.superview.layer setShadowColor:[UIColor blackColor].CGColor];
             [newestPhotoCell.photo.superview.layer setShadowOpacity:0.25];
             [newestPhotoCell.photo.superview.layer setShadowRadius:1.0];
             [newestPhotoCell.photo.superview.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
             
             
             // set details of private or not
             if ([photo.permission boolValue] == NO)
                 newestPhotoCell.private.hidden=NO;
             else
                 newestPhotoCell.private.hidden=YES;
             
             
             // set details geoposition
             if (photo.latitude != nil && photo.longitude != nil){
                 // show button
                 newestPhotoCell.geoPositionButton.hidden=NO;
                 
                 // set the latitude and longitude
                 newestPhotoCell.geoPosition = [NSString stringWithFormat:@"%@,%@",photo.latitude,photo.longitude];
             }else {
                 newestPhotoCell.geoPositionButton.hidden=YES;
             }
             
             // share details
             if (photo.photoUrl != nil && [PropertiesConfiguration isHostedUser]){
                 newestPhotoCell.shareButton.hidden=NO;
                 newestPhotoCell.photoPageUrl = photo.photoPageUrl;
                 newestPhotoCell.newestPhotosTableViewController = self;
             }else{
                 newestPhotoCell.shareButton.hidden=YES;
             }
         }
                                       failure:^(NSError *error) 
         {
             OpenPhotoAlertView *alert = [[OpenPhotoAlertView alloc] initWithMessage:@"Couldn't download the image" duration:5000];
             [alert showAlert];
             [alert release];
             
         }];
        
        
        return newestPhotoCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TimelinePhotos *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([photo.status isEqualToString:kUploadStatusTypeUploaded]){
        return 365;
    }else{
        return 44;
    }
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // get the object
    TimelinePhotos *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
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
        TimelinePhotos *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[AppDelegate managedObjectContext] deleteObject:photo];
    }
}

- (void) deleteTimeline:(TimelinePhotos *) photo
{
    [[AppDelegate managedObjectContext] deleteObject:photo];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)doneLoadingTableViewData
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
    // if no picture, show image to upload
    if ([[self.fetchedResultsController fetchedObjects] count]== 0){
        [self.navigationController.view addSubview:self.noPhotoImageView];
        self.noPhotoImageView.hidden = NO;
    }else{
        [self.noPhotoImageView removeFromSuperview];
    }
}



#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{  
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    // via GCD, get the newest photos and save it on database
    [self loadNewestPhotosIntoCoreData];    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _reloading; // should return if data source model is reloading	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{	
    return [NSDate date]; // should return date data source was last changed	
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    _refreshHeaderView=nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) dealloc 
{    
    [_refreshHeaderView release];
    [self.noPhotoImageView release];
    [coreLocationController release];
    [self.fetchedResultsController release];
    [super dealloc];
}



#pragma mark -
#pragma mark Population core data
- (void) loadNewestPhotosIntoCoreData
{
    if (_reloading == NO){
        // set reloading in the table
        _reloading = YES;
        
        // if there isn't netwok
        if ( [AppDelegate internetActive] == NO ){
            [self notifyUserNoInternet];
            [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
        }else {
            dispatch_queue_t loadNewestPhotos = dispatch_queue_create("loadNewestPhotos", NULL);
            dispatch_async(loadNewestPhotos, ^{
                // call the method and get the details
                @try {
                    // get factory for OpenPhoto Service
                    OpenPhotoService *service = [OpenPhotoServiceFactory createOpenPhotoService];
                    NSArray *result = [service fetchNewestPhotosMaxResult:25];
                    [service release];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // let NewestPhotos treat the objects
                        [TimelinePhotos insertIntoCoreData:result InManagedObjectContext:[AppDelegate managedObjectContext]];  
                        [self doneLoadingTableViewData];
                    });
                }@catch (NSException *exception) {
                    dispatch_async(dispatch_get_main_queue(), ^{                  
                        OpenPhotoAlertView *alert = [[OpenPhotoAlertView alloc] initWithMessage:@"Failed! We couldn't get your newest photos." duration:5000];
                        [alert showAlert];
                        [alert release];
                        
                        // refresh table  
                        [self doneLoadingTableViewData];
                    });   
                }
            });
            dispatch_release(loadNewestPhotos);
        }
    }
}

- (void) notifyUserNoInternet{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // problem with internet, show message to user    
    OpenPhotoAlertView *alert = [[OpenPhotoAlertView alloc] initWithMessage:@"Failed! Check your internet connection" duration:5000];
    [alert showAlert];
    [alert release];
}

- (void) eventHandler: (NSNotification *) notification{
#ifdef DEVELOPMENT_ENABLED    
    NSLog(@"###### Event triggered: %@", notification);
#endif
    
    if ([notification.name isEqualToString:kNotificationNeededsUpdateHome]){
        [self loadNewestPhotosIntoCoreData];
    }else if ([notification.name isEqualToString:kNotificationDisableUpdateHome]){
        self.needsUpdate = NO;   
    }
}
@end
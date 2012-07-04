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
- (void)doneLoadingTableViewData;
@end

@implementation HomeTableViewController
@synthesize noPhotoImageView=_noPhotoImageView;


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
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];   
    [self loadNewestPhotosIntoCoreData];
    
#ifdef TEST_FLIGHT_ENABLED
    [TestFlight passCheckpoint:@"Newest Photos Loaded"];
#endif
    
    // ask if user wants to enable location
    [coreLocationController.locMgr startUpdatingLocation];    
    [coreLocationController.locMgr stopUpdatingLocation];  
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TimelinePhotos" inManagedObjectContext:[AppDelegate managedObjectContext]];
    [fetchRequest setEntity:entity];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateUploaded" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[AppDelegate managedObjectContext]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:@"cache_for_home_screen"];
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
        }
        
        
        
        // set the upload photo object in the cell for restart or cancel
        uploadCell.originalObject = photo;
        
        // delegation
        uploadCell.delegate = self;
        
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
        if ( [photo.status isEqualToString:kUploadStatusTypeCreated]){
            uploadCell.status.text=@"Waiting ...";
            [uploadCell.imageStatus setImage:[UIImage imageNamed:@"home-waiting.png"]];
            uploadCell.imageStatus.hidden=NO;
        }else if ( [photo.status isEqualToString:kUploadStatusTypeUploading]){
            uploadCell.status.text=@"Uploading";
        }else if ( [photo.status isEqualToString:kUploadStatusTypeUploaded]){
            uploadCell.status.text=@"Upload finished!";
            [uploadCell.imageStatus setImage:[UIImage imageNamed:@"home-finished.png"]];
            uploadCell.imageStatus.hidden=NO;
        }else if ( [photo.status isEqualToString:kUploadStatusTypeFailed]){
            uploadCell.status.text=@"Retry uploading";
        }
        
        // decide if we show retry/cancel
        if (![photo.status isEqualToString:kUploadStatusTypeFailed]) {
            uploadCell.btnRetry.hidden  = YES;
        }else{
            uploadCell.btnRetry.hidden  = NO;
        }
        
        // set ativity icon
        if (![photo.status isEqualToString:kUploadStatusTypeUploading]) {
            [uploadCell.activity stopAnimating];
        }
        
        
        /*
         // start upload
         if ([upload.status isEqualToString:kUploadStatusTypeCreated]){
         // check if there is internet
         if ([AppDelegate internetActive] == NO ){
         // if not, set as failed
         [self notifyUserNoInternet];
         uploadCell.status.text = kUploadStatusTypeFailed;
         upload.status = kUploadStatusTypeFailed;
         uploadCell.btnRetry.hidden  = NO;
         uploadCell.imageStatus.hidden=YES;
         
         NSError *saveError = nil;
         if (![[AppDelegate managedObjectContext] save:&saveError]){
         NSLog(@"Error on cancel the item from cell = %@",[saveError localizedDescription]);
         }
         }else if ([UploadPhotos howManyUploadingInManagedObjectContext:[AppDelegate managedObjectContext]] < 3 ){
         // set the status to Uploading, in case of max 3 uploading - we don't wanna have too many uploads
         upload.status = kUploadStatusTypeUploading;
         uploadCell.status.text = @"Uploading";
         uploadCell.imageStatus.hidden=YES;
         
         // start progress bar and update screen
         [uploadCell.activity startAnimating];
         
         NSDictionary *dictionary = nil;
         @try {
         dictionary = [upload toDictionary];
         }
         @catch (NSException *e) {
         // check if it is duplicated
         NSString *alertMessage = [[NSString alloc] initWithFormat:@"Failed! %@",[e description]];
         
         OpenPhotoAlertView *alert = [[OpenPhotoAlertView alloc] initWithMessage:alertMessage duration:5000];
         [alert showAlert];
         [alert release];
         
         upload.status = kUploadStatusTypeFailed;
         uploadCell.status.text = kUploadStatusTypeFailed;
         uploadCell.btnRetry.hidden  = NO;
         
         NSError *saveError = nil;
         if (![[AppDelegate managedObjectContext] save:&saveError]){
         NSLog(@"Error on cancel the item from cell = %@",[saveError localizedDescription]);
         }
         
         [self.tableView beginUpdates];
         [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] 
         withRowAnimation:UITableViewRowAnimationFade];
         [self.tableView endUpdates];
         
         return uploadCell;
         }
         
         
         
         // create gcd and start upload
         dispatch_queue_t uploadQueue = dispatch_queue_create("uploader_queue", NULL);
         dispatch_async(uploadQueue, ^{
         
         @try{
         
         // prepare the data to upload
         NSString *filename = [dictionary objectForKey:@"fileName"];
         NSData *data = [dictionary objectForKey:@"image"];
         
         // create the service, check photo exists and send the request
         OpenPhotoService *service = [OpenPhotoServiceFactory createOpenPhotoService];
         
         // before check if the photo already exist
         if ([service isPhotoAlreadyOnServer:[SHA1 sha1File:data]]){
         @throw  [NSException exceptionWithName: @"Failed to upload" reason:@"You already uploaded this photo." userInfo: nil];
         }else{
         NSDictionary *response = [service uploadPicture:data metadata:dictionary fileName:filename];
         [service release];
         #ifdef DEVELOPMENT_ENABLED                        
         NSLog(@"Photo uploaded correctly");
         #endif
         // update the screen
         dispatch_async(dispatch_get_main_queue(), ^{
         // if it is processed change the status UPLOADED
         //                                uploadCell.status.text = @"Upload finished!!!";
         //                              [uploadCell.imageStatus setImage:[UIImage imageNamed:@"upload-finished.png"]];
         //                            uploadCell.imageStatus.hidden=NO;
         upload.status = kUploadStatusTypeUploaded;
         
         [self.uploads replaceObjectAtIndex:indexPath.row withObject:upload];
         
         NSError *saveError = nil;
         if (![[AppDelegate managedObjectContext] save:&saveError]){
         NSLog(@"Error on change status of Upload = %@",[saveError localizedDescription]);
         }
         
         #ifdef TEST_FLIGHT_ENABLED
         [TestFlight passCheckpoint:@"Image uploaded"];
         #endif
         
         [self.tableView beginUpdates];
         [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] 
         withRowAnimation:UITableViewRowAnimationFade];
         [self.tableView endUpdates]; 
         
         // update the table with newest photos
         [self loadNewestPhotosIntoCoreData];
         
         // check if it needs share for twitter or facebook
         // prepare NSDictionary with details of sharing if Twitter or Facebook was checked
         if ([upload.twitter boolValue] ||  [upload.facebook boolValue]){
         #ifdef DEVELOPMENT_ENABLED
         NSLog(@"User wants to share uploaded photo");
         #endif
         NSDictionary *responsePhoto = [response objectForKey:@"result"] ;
         
         NSError *saveError = nil;
         if (![[AppDelegate managedObjectContext] save:&saveError]){
         NSLog(@"Error on cancel the item from cell = %@",[saveError localizedDescription]);
         }          
         #ifdef TEST_FLIGHT_ENABLED
         
         if ([upload.twitter boolValue]){
         [TestFlight passCheckpoint:@"Twitter"];
         }else{
         // facebook
         [TestFlight passCheckpoint:@"Facebook"];
         }
         #endif
         
         // parameters from upload
         NSArray *keys = [NSArray arrayWithObjects:@"url", @"title",@"type",nil];
         NSString *shareDetails = [responsePhoto objectForKey:@"url"];                              
         NSArray *objects= [NSArray arrayWithObjects: shareDetails, [NSString stringWithFormat:@"%@", [responsePhoto objectForKey:@"title"]],[upload.twitter boolValue] ? @"Twitter" : @"Facebook", nil];
         [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShareInformationToFacebookOrTwitter object:[NSDictionary dictionaryWithObjects:objects forKeys:keys] ];       
         }  
         });
         }
         }@catch (NSException* e) {
         NSLog(@"Error %@",e);
         
         // if it fails for any reason, set status FAILED in the main thread
         dispatch_async(dispatch_get_main_queue(), ^{
         
         // default for all erros
         upload.status = kUploadStatusTypeFailed;
         uploadCell.status.text = @"Failed";
         uploadCell.btnRetry.hidden  = NO;
         
         // check if it is duplicated
         if ([[e description] hasPrefix:@"Error: 409 - This photo already exists based on a"] ||
         [[e description] hasPrefix:@"You already uploaded this photo."]){
         
         // can considere the image as uploaded
         uploadCell.status.text = @"Duplicated";
         [uploadCell.imageStatus setImage:[UIImage imageNamed:@"home-already-uploaded.png"]];
         uploadCell.imageStatus.hidden=NO;
         upload.status = kUploadStatusTypeUploaded;
         uploadCell.btnRetry.hidden  = YES;  
         [self.tableView beginUpdates];
         [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] 
         withRowAnimation:UITableViewRowAnimationFade];
         [self.tableView endUpdates]; 
         }else {
         NSString *alertMessage = [[NSString alloc] initWithFormat:@"Failed! %@",[e description]];
         OpenPhotoAlertView *alert = [[OpenPhotoAlertView alloc] initWithMessage:alertMessage duration:5000];
         [alert showAlert];
         [alert release];
         }
         
         NSError *saveError = nil;
         if (![[AppDelegate managedObjectContext] save:&saveError]){
         NSLog(@"Error on cancel the item from cell = %@",[saveError localizedDescription]);
         }
         
         [self doneLoadingTableViewData];                            
         });
         }
         });
         dispatch_release(uploadQueue);
         
         }else{
         NSLog(@"Number max of uploading reached");
         }
         }
         */
        return uploadCell;
    }else{
        
        NewestPhotoCell *newestPhotoCell = (NewestPhotoCell *)[tableView dequeueReusableCellWithIdentifier:photoCellIdentifier];
        
        if (newestPhotoCell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NewestPhotoCell" owner:nil options:nil];
            newestPhotoCell = [topLevelObjects objectAtIndex:0];
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
        
        //Load images from web asynchronously with GCD 
        if(!photo.photoData && photo.photoUrl != nil){
            newestPhotoCell.photo.hidden = YES;
            newestPhotoCell.private.hidden = YES;
            newestPhotoCell.geoPositionButton.hidden=YES;
            newestPhotoCell.shareButton.hidden=YES;
            
            [newestPhotoCell.activity startAnimating];
            newestPhotoCell.activity.hidden = NO;
            
            if ( [AppDelegate internetActive] == YES ){
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:photo.photoUrl]];
                    
#ifdef DEVELOPMENT_ENABLED 
                    NSLog(@"URL do download is = %@",photo.photoUrl);
#endif
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        photo.photoData = data;
                        UIImage *thumbnail = [UIImage imageWithData:data];
                        
                        // set details on cell
                        [newestPhotoCell.activity stopAnimating];
                        newestPhotoCell.activity.hidden = YES;
                        newestPhotoCell.photo.hidden = NO;               
                        newestPhotoCell.photo.image = thumbnail;
                    });
                });
            }
        }else{
            newestPhotoCell.photo.image = [UIImage imageWithData:photo.photoData];
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
    
    /*
     // just in case of upload
     if ([self.uploads count] > 0 && indexPath.row < [self.uploads count]){
     // Return YES in case of Failed only
     UploadPhotos *upload = [self.uploads objectAtIndex:indexPath.row];
     if ( [upload.status isEqualToString:kUploadStatusTypeFailed]){
     return YES;
     
     }
     }
     */
    
    // others no
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    /* 
     if (editingStyle == UITableViewCellEditingStyleDelete) {
     #ifdef DEVELOPMENT_ENABLED
     NSLog(@"Pressed delete button");
     #endif
     // delete object originalObject
     UploadPhotos *upload = [self.uploads objectAtIndex:indexPath.row];
     [[AppDelegate managedObjectContext] deleteObject:upload];
     
     NSError *saveError = nil;
     if (![[AppDelegate managedObjectContext] save:&saveError]){
     NSLog(@"Error on delete the item from cell = %@",[saveError localizedDescription]);
     }
     
     [self doneLoadingTableViewData];
     }    
     
     */
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
                    NSArray *result = [service fetchNewestPhotosMaxResult:50];
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
@end
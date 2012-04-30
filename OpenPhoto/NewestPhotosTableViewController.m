//
//  NewestPhotosTableViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 26/03/12.
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

@interface NewestPhotosTableViewController ()
- (void) loadNewestPhotosIntoCoreData;
- (void)doneLoadingTableViewData;
@end

@implementation NewestPhotosTableViewController
@synthesize uploads=_uploads, newestPhotos=_newestPhotos;
@synthesize noPhotoImageView=_noPhotoImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // transparent background
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.opaque = NO;
        self.tableView.backgroundView = nil;
        
        UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Background.png"]];
        self.view.backgroundColor = background;
        [background release];
        
        self.tableView.separatorColor = UIColorFromRGB(0xC8BEA0);
        
        // clean table when log out    
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(eventHandler:)
                                                     name:kNotificationLoginNeeded       
                                                   object:nil ];
        
        CGRect imageSize = CGRectMake(0, 63, 320, 367);
        self.noPhotoImageView = [[UIImageView alloc] initWithFrame:imageSize];
        self.noPhotoImageView.image = [UIImage imageNamed:@"home-upload-now.png"];
        self.noPhotoImageView.hidden = YES;
        
        coreLocationController = [[CoreLocationController alloc] init];
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height) arrowImageName:@"blueArrow.png" textColor:UIColorFromRGB(0xC8BEA0)];
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
    
    // set details for uploads
    self.uploads = [NSMutableArray arrayWithArray:[UploadPhotos getUploadsNotUploadedInManagedObjectContext:[AppDelegate managedObjectContext]]];
    
    // set details for newestPhotos
    self.newestPhotos = [NewestPhotos getNewestPhotosInManagedObjectContext:[AppDelegate managedObjectContext]];  
    
    // when loads for the first time, delete all UPLOADED uploads
    [UploadPhotos deleteUploadedInManagedObjectContext:[AppDelegate managedObjectContext]];
    
}


- (void) updateNeededForUploadDataSource{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Delegate invoked");
#endif
    
    self.uploads = [NSMutableArray arrayWithArray:[UploadPhotos getUploadsNotUploadedInManagedObjectContext:[AppDelegate managedObjectContext]]];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.uploads count] + [self.newestPhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *photoCellIdentifier = @"photoCell";
    static NSString *uploadCellIdentifier = @"uploadCell";
    
    // first decide if we have to show a upload cell or photo cell
    if ([self.uploads count] > 0 && indexPath.row < [self.uploads count]){
        // in this case, we have uploads and the cell must be a upload cell
        UploadCell *uploadCell= (UploadCell *)[tableView dequeueReusableCellWithIdentifier:uploadCellIdentifier];
        
        if (uploadCell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UploadCell" owner:nil options:nil];
            uploadCell = [topLevelObjects objectAtIndex:0];
        }
        
        UploadPhotos *upload = [self.uploads objectAtIndex:indexPath.row];
        
        // set the upload photo object in the cell for restart or cancel
        uploadCell.originalObject = upload;
        
        // delegation
        uploadCell.delegate = self;
        
        // set thumb
        CGSize itemSize = CGSizeMake(70, 70);
        UIGraphicsBeginImageContext(itemSize);
        
        UIImage *image =  [UIImage imageWithData:upload.image];
        [image drawInRect:CGRectMake(0, 0, 70, 70)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData* imageData1 =[NSData dataWithData:UIImagePNGRepresentation (image)]; 
        uploadCell.thumb.image = [UIImage imageWithData:imageData1];   
        
        // set status
        uploadCell.status.text = upload.status;
        
        // decide if we show retry/cancel
        if (![upload.status isEqualToString:kUploadStatusTypeFailed]) {
            uploadCell.btnRetry.hidden  = YES;
            uploadCell.btnCancel.hidden = YES;
        }else{
            uploadCell.btnRetry.hidden  = NO;
            uploadCell.btnCancel.hidden = NO;
        }
        
        // set ativity icon
        if (![upload.status isEqualToString:kUploadStatusTypeUploading]) {
            [uploadCell.activity stopAnimating];
        }
        
        // start upload
        if ([upload.status isEqualToString:kUploadStatusTypeCreated]){
            // check if there is internet
            if ([AppDelegate internetActive] == NO ){
                // if not, set as failed
                [self notifyUserNoInternet];
                uploadCell.status.text = kUploadStatusTypeFailed;
                upload.status = kUploadStatusTypeFailed;
                uploadCell.btnRetry.hidden  = NO;
                uploadCell.btnCancel.hidden = NO;
            }else if ([UploadPhotos howManyUploadingInManagedObjectContext:[AppDelegate managedObjectContext]] <= 3 ){
                // set the status to Uploading, in case of max 3 uploading - we don't wanna have too many uploads
                uploadCell.status.text = kUploadStatusTypeUploading;
                upload.status = kUploadStatusTypeUploading;
                
                // start progress bar and update screen
                [uploadCell.activity startAnimating];
                
                NSDictionary *dictionary = [upload toDictionary];
                
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
                            @throw  [NSException exceptionWithName: @"Failed to upload" reason: @"You already uploaded this photo." userInfo: nil];
                        }else{
                            NSDictionary *response = [service uploadPicture:data metadata:dictionary fileName:filename];
                            [service release];
#ifdef DEVELOPMENT_ENABLED                        
                            NSLog(@"Photo uploaded correctly");
#endif
                            // update the screen
                            dispatch_async(dispatch_get_main_queue(), ^{
                                // if it is processed change the status UPLOADED
                                uploadCell.status.text = kUploadStatusTypeUploaded;
                                upload.status = kUploadStatusTypeUploaded;
                                // while we do not delete this photo, save space removing the image
                                upload.image = nil;
                                
                                NSError *saveError = nil;
                                if (![[AppDelegate managedObjectContext] save:&saveError]){
                                    NSLog(@"Error on change status of Upload = %@",[saveError localizedDescription]);
                                }
                                
#ifdef TEST_FLIGHT_ENABLED
                                [TestFlight passCheckpoint:@"Image uploaded"];
#endif
                                
                                // check if it needs share for twitter or facebook
                                // prepare NSDictionary with details of sharing if Twitter or Facebook was checked
                                if ([upload.twitter boolValue] ||  [upload.facebook boolValue]){
#ifdef DEVELOPMENT_ENABLED
                                    NSLog(@"User wants to share uploaded photo");
#endif
                                    NSDictionary *responsePhoto = [response objectForKey:@"result"] ;
                                    
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
                                
                                // reload list
                                [self.uploads removeObjectAtIndex:indexPath.row];
                                
                                // table needs update
                                [self.tableView reloadData]; 
                                
                                // update the table with newest photos
                                [self loadNewestPhotosIntoCoreData];
                            });
                        }
                    }@catch (NSException* e) {
                        NSLog(@"Error %@",e);
                        
                        // if it fails for any reason, set status FAILED in the main thread
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            // check if it is duplicated
                            NSString *alertMessage;
                            if ([[e description] hasPrefix:@"Error: 409 - This photo already exists based on a"]){
                                alertMessage = [[NSString alloc] initWithFormat:@"Failed to upload: You already uploaded this photo."];
                            }else {
                                alertMessage = [[NSString alloc] initWithFormat:@"Failed to upload: %@",[e description]];
                            }
                            
                            OpenPhotoAlertView *alert = [[OpenPhotoAlertView alloc] initWithMessage:alertMessage duration:5000];
                            [alert showAlert];
                            [alert release];
                            
                            upload.status = kUploadStatusTypeFailed;
                            uploadCell.status.text = kUploadStatusTypeFailed;
                            uploadCell.btnRetry.hidden  = NO;
                            uploadCell.btnCancel.hidden = NO;
                            
                            [self.tableView beginUpdates];
                            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] 
                                                  withRowAnimation:UITableViewRowAnimationFade];
                            [self.tableView endUpdates]; 
                            
                        });
                    }
                });
                dispatch_release(uploadQueue);
                
            }else{
                NSLog(@"Number max of uploading reached");
            }
        }
        return uploadCell;
    }else{
        int newestPhotosIndex = indexPath.row;
        if ([self.uploads count] > 0 && indexPath.row >= [self.uploads count]){
            // in this case, we have uploads but the cell to show is a photo cell
            newestPhotosIndex = indexPath.row - [self.uploads count];
        }    
        
        NewestPhotoCell *newestPhotoCell = (NewestPhotoCell *)[tableView dequeueReusableCellWithIdentifier:photoCellIdentifier];
        
        if (newestPhotoCell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NewestPhotoCell" owner:nil options:nil];
            newestPhotoCell = [topLevelObjects objectAtIndex:0];
        }
        
        NewestPhotos *photo = [self.newestPhotos objectAtIndex:newestPhotosIndex];
        
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
                        
                        [self.tableView beginUpdates];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] 
                                              withRowAnimation:UITableViewRowAnimationNone];
                        [self.tableView endUpdates]; 
                        
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
        }
        
        return newestPhotoCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.uploads count] > 0 && indexPath.row < [self.uploads count]){
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }else{
        return 365;
    }
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)doneLoadingTableViewData
{
    //  model should call this when its done loading
    self.uploads = [NSMutableArray arrayWithArray:[UploadPhotos getUploadsNotUploadedInManagedObjectContext:[AppDelegate managedObjectContext]]];
    self.newestPhotos = [NewestPhotos getNewestPhotosInManagedObjectContext:[AppDelegate managedObjectContext]];  
    [self.tableView reloadData];
    
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
    
    // if no picture, show image to upload
    if (  [self.uploads count] + [self.newestPhotos count] == 0  ) {
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

- (void) eventHandler: (NSNotification *) notification{   
    if ([notification.name isEqualToString:kNotificationLoginNeeded]){
        self.newestPhotos = [NSArray array];
        self.uploads = [NSArray array];
        [self.tableView reloadData];
    }
}

- (void) dealloc 
{    
    [_refreshHeaderView release];
    [self.newestPhotos release];
    [self.uploads release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.noPhotoImageView release];
    [coreLocationController release];
    [super dealloc];
}



#pragma mark -
#pragma mark Population core data
- (void) loadNewestPhotosIntoCoreData
{
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
                NSArray *result = [service fetchNewestPhotosMaxResult:5];
                [service release];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // let NewestPhotos treat the objects
                    [NewestPhotos insertIntoCoreData:result InManagedObjectContext:[AppDelegate managedObjectContext]];  
                    [self doneLoadingTableViewData];
                });
            }@catch (NSException *exception) {
                dispatch_async(dispatch_get_main_queue(), ^{                  
                    OpenPhotoAlertView *alert = [[OpenPhotoAlertView alloc] initWithMessage:@"We couldn't get your newest photos from the server" duration:5000];
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

- (void) notifyUserNoInternet{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // problem with internet, show message to user    
    OpenPhotoAlertView *alert = [[OpenPhotoAlertView alloc] initWithMessage:@"Couldn't reach the server. Please, check your internet connection" duration:5000];
    [alert showAlert];
    [alert release];
}
@end
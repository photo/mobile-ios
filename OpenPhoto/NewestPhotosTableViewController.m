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
@end

@implementation NewestPhotosTableViewController
@synthesize uploads, newestPhotos;

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
        
        // clean table when log out    
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(eventHandler:)
                                                     name:kNotificationLoginNeeded       
                                                   object:nil ];
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];   
    [self loadNewestPhotosIntoCoreData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
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
    self.uploads = [NSMutableArray arrayWithArray:[UploadPhotos getUploadsInManagedObjectContext:[AppDelegate managedObjectContext]]];
    
    // set details for newestPhotos
    self.newestPhotos = [NewestPhotos getNewestPhotosInManagedObjectContext:[AppDelegate managedObjectContext]];  
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
        
        // set thumb
        
        // set status
        uploadCell.status.text = upload.status;
        
        // decide if we show retry/cancel
        if (![upload.status isEqualToString:kUploadStatusTypeFailed]) {
            uploadCell.btnRetry.hidden  = YES;
            uploadCell.btnCancel.hidden = YES;
        }
        
        // set ativity icon
        if (![upload.status isEqualToString:kUploadStatusTypeUploading]) {
            [uploadCell.activity stopAnimating];
        }
        
        // start upload
        if ([upload.status isEqualToString:kUploadStatusTypeCreated]){
            // check if there is internet
            
            // if not, set as failed
            
            // set the status to Uploading, in case of max 3 uploading - we don't wanna have too many uploads
            if ([UploadPhotos howManyUploadingInManagedObjectContext:[AppDelegate managedObjectContext]] <= 0 ){
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
                        
                        // create the service and send the request
                        OpenPhotoService *service = [OpenPhotoServiceFactory createOpenPhotoService];
                        [service uploadPicture:data metadata:dictionary fileName:filename];
                        
                        // update the screen
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // if it is processed change the status UPLOADED
                            uploadCell.status.text = kUploadStatusTypeUploaded;
                            upload.status = kUploadStatusTypeUploaded;
                            
                            // reload list
                            [self.uploads removeObjectAtIndex:indexPath.row];
                            
                            // table needs update
                            [self.tableView reloadData]; 
                        });
                    }@catch (NSException* e) {
                        // if it fails for any reason, set status FAILED in the main thread
                        dispatch_async(dispatch_get_main_queue(), ^{
                            upload.status = kUploadStatusTypeFailed;
                            uploadCell.status.text = kUploadStatusTypeFailed;
                            
                            [self.tableView beginUpdates];
                            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] 
                                                  withRowAnimation:UITableViewRowAnimationFade];
                            [self.tableView endUpdates]; 
                            
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to upload" message:[e description]
                                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                            [alert release];
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
        if (days >= 2){
            // lets show in days
            [dateText appendFormat:@"%i days ago",days];
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
            [newestPhotoCell.activity startAnimating];
            newestPhotoCell.activity.hidden = NO;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:photo.photoUrl]];
                NSLog(@"URL do download is = %@",photo.photoUrl);
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
        }else{
            newestPhotoCell.photo.image = [UIImage imageWithData:photo.photoData];
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

- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
    self.uploads = [NSMutableArray arrayWithArray:[UploadPhotos getUploadsInManagedObjectContext:[AppDelegate managedObjectContext]]];
    self.newestPhotos = [NewestPhotos getNewestPhotosInManagedObjectContext:[AppDelegate managedObjectContext]];  
    [self.tableView reloadData];
    
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
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
    }
}

- (void)dealloc 
{    
    [_refreshHeaderView release];
    [newestPhotos release];
    [uploads release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}



#pragma mark -
#pragma mark Population core data
-(void) loadNewestPhotosIntoCoreData{
    // set reloading in the table
    _reloading = YES;
    
    // get factory for OpenPhoto Service
    OpenPhotoService *service = [OpenPhotoServiceFactory createOpenPhotoService];
    
    dispatch_queue_t loadNewestPhotos = dispatch_queue_create("loadNewestPhotos", NULL);
    dispatch_async(loadNewestPhotos, ^{
        // call the method and get the details
        NSArray *result = [service fetchNewestPhotosMaxResult:5];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // let NewestPhotos treat the objects
            [NewestPhotos insertIntoCoreData:result InManagedObjectContext:[AppDelegate managedObjectContext]];  
            [self doneLoadingTableViewData];
        });
    });
    dispatch_release(loadNewestPhotos);
}

- (void) notifyUserNoInternet{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // problem with internet, show message to user
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet error" message:@"Couldn't reach the server. Please, check your internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}
@end
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
    self.uploads = [Uploads getUploadsInManagedObjectContext:[AppDelegate managedObjectContext]];
    
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
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
    NewestPhotos *photo = [self.newestPhotos objectAtIndex:indexPath.row];
  
    if (photo.title != nil)
    cell.textLabel.text=photo.title;
	
    
    //Load images from web asynchronously with GCD 
    if(!photo.photoData){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:photo.photoUrl]];
            dispatch_sync(dispatch_get_main_queue(), ^{
                photo.photoData = data;
                UIImage *thumbnail = [UIImage imageWithData:data];
                cell.imageView.image = thumbnail;
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] 
                                      withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates]; 
                
            });
        });
    }
    else
        cell.imageView.image = [UIImage imageWithData:photo.photoData];
    
    return cell;
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
    self.uploads = [Uploads getUploadsInManagedObjectContext:[AppDelegate managedObjectContext]];
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
    [service retain];
    
    dispatch_queue_t loadNewestPhotos = dispatch_queue_create("loadNewestPhotos", NULL);
    dispatch_async(loadNewestPhotos, ^{
        // call the method and get the details
        NSArray *result = [service fetchNewestPhotosMaxResult:5];
        
        [service release];
        dispatch_async(dispatch_get_main_queue(), ^{
            // let NewestPhotos treat the objects
            [NewestPhotos insertIntoCoreData:result InManagedObjectContext:[AppDelegate managedObjectContext]];  
            [self doneLoadingTableViewData];
        });
    });
    dispatch_release(loadNewestPhotos);
}
@end
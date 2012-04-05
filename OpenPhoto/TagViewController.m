//
//  TagViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 11/08/11.
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

#import "TagViewController.h"

@interface TagViewController()
- (void) loadTags;
@property (nonatomic) BOOL readOnly;
@end

@implementation TagViewController

@synthesize tags = _tags;
@synthesize readOnly = _readOnly;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"BackgroundUpload.png"]];
        
        // initialize the object tags
        self.tags = [[NSMutableArray alloc] init];    
        
        // set the read only by default as NO 
        self.readOnly = NO;
        
        // color separator
        self.tableView.separatorColor = UIColorFromRGB(0xC8BEA0);
    }
    return self;
}

-(void) dealloc
{
    [self.tags release];
    [_refreshHeaderView release];
    [super dealloc];
}
- (void) setReadOnly
{
    self.readOnly = YES;
}

// this method return only the tag's name.
- (NSArray*) getSelectedTags
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (id object in self.tags) {
        Tag *tag = (Tag*) object;
        if (tag.selected == YES){
            [array addObject:tag.tagName];  
        }
    }
    
    return array;
}

// this method return the tag's name but in the format to send to openphoto server
- (NSString *) getSelectedTagsInJsonFormat
{  
    NSMutableString *result = [NSMutableString string];
    
    NSArray *array = [self getSelectedTags];
    int counter = 1;
    
    if (array != nil && [array count]>0){
        for (id string in array) {
            [result appendFormat:@"%@",string];
            
            // add the ,
            if ( counter < [array count]){
                [result appendFormat:@", "];
            }
            
            counter++;
        }
    }
    
    return result;
}

#pragma mark - View lifecycle
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // wanna add new tag name
    if (self.readOnly == YES){
        UIBarButtonItem *addNewTagButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewTag)];          
        self.navigationItem.rightBarButtonItem = addNewTagButton;
        [addNewTagButton release];
        
        if ([self.tags count] == 0 ){
            // just load in case there is no tags.
            // we do that to keep the past selection
            [self loadTags];
        }
    }else{
        // load all tags
        [self loadTags];     
    }
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set the tile of the table
    self.title=@"Tags"; 
    
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
}

-(void) addNewTag
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Adding new tag");
#endif
    
    TSAlertView* av = [[TSAlertView alloc] initWithTitle:@"Enter new tag name" message:nil delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"OK",nil];
    av.style = TSAlertViewStyleInput;
    [av show];
    [av release];
}

// after animation
- (void) alertView: (TSAlertView *) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex
{
    // cancel
    if( buttonIndex == 0 || alertView.inputTextField.text == nil || alertView.inputTextField.text.length==0)
        return;
    
    // add the new tag in the list and select it
    Tag *newTag = [[Tag alloc]initWithTagName:alertView.inputTextField.text Quantity:0];
    newTag.selected = YES;
    [self.tags addObject:newTag];
    
    // we don't need it anymore.
    [newTag release];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    NSUInteger row = [indexPath row];
    
    Tag *tag = [self.tags objectAtIndex:row];
    cell.textLabel.text=tag.tagName;
    if (self.readOnly == NO){
        
        // details quantity
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%d", tag.quantity];
        cell.detailTextLabel.textColor = UIColorFromRGB(0xE6501E);
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        // check if it selected or not
        if(tag.selected == YES)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else 
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the tag
    NSUInteger row = [indexPath row];
    Tag *tag = [self.tags objectAtIndex:row];
    
    if (tag.quantity >0 && self.readOnly == NO){
        // open the gallery with a tag that contains at least one picture.
        GalleryViewController *galleryController = [[GalleryViewController alloc]initWithTagName:tag.tagName];
        [self.navigationController pushViewController:galleryController animated:YES];
        [galleryController release];
    }
    
    if (self.readOnly == YES){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSUInteger row = [indexPath row];
        Tag *tag = [self.tags objectAtIndex:row];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            tag.selected = NO;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            tag.selected = YES;
        }
    }
}


#pragma mark
#pragma mark - Methods to get Tags via json
- (void) loadTags
{
    // if there isn't netwok
    if ( [AppDelegate internetActive] == NO ){
        // problem with internet, show message to user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet error" message:@"Couldn't reach the server. Please, check your internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
    }else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"Loading  ";
        
        dispatch_queue_t loadTags = dispatch_queue_create("loadTags", NULL);
        dispatch_async(loadTags, ^{
            // call the method and get the details
            @try {
                // get factory for OpenPhoto Service
                OpenPhotoService *service = [OpenPhotoServiceFactory createOpenPhotoService];
                NSArray *result = [service getTags];
                [service release];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tags removeAllObjects];
                    if ([result class] != [NSNull class]) {
                        // Loop through each entry in the dictionary and create an array Tags
                        for (NSDictionary *tagDetails in result){
                            // tag name       
                            NSString *name = [tagDetails objectForKey:@"id"];
                            name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            
                            // how many images
                            NSString *qtd = [tagDetails objectForKey:@"count"];
                            
                            // create a tag and add to the list
                            Tag *tag = [[Tag alloc]initWithTagName:name Quantity:[qtd integerValue]];
                            tag.selected = NO;
                            [self.tags addObject:tag];
                            
                            // we don't need it anymore.
                            [tag release];
                        }}
                    
                    [self.tableView reloadData];
                    
#ifdef TEST_FLIGHT_ENABLED
                    [TestFlight passCheckpoint:@"Tags received from the website"];
#endif
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    
                    // refresh table  
                    [self doneLoadingTableViewData];
                });
            }@catch (NSException *exception) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:exception.description delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                    
                    // refresh table  
                    [self doneLoadingTableViewData];
                    
                });   
            }
        });
        dispatch_release(loadTags);
    }
    
}

- (void)doneLoadingTableViewData
{
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
    // via GCD, get tall tags
    [self loadTags];    
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

@end
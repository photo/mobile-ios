//
//  AlbumViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 09/10/12.
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

#import "AlbumViewController.h"

@interface AlbumViewController ()
- (void) loadAlbums;
- (NSArray *) getSelectedAlbums;
- (void) loadAlbumsForV1:(NSArray *) result;
- (void) loadAlbumsForV2:(NSArray *) result;

//used for create new albums
@property (nonatomic) BOOL readOnly;

// for infinite scroll
@property (nonatomic) NSInteger page;
@property (nonatomic) NSInteger totalPages;

@end

@implementation AlbumViewController

@synthesize albums = _albums, readOnly=_readOnly;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // initialize the object albums
        self.albums = [NSMutableArray array];
        self.readOnly = NO;
        
        // for infinite scroll
        self.page = 1;
        self.totalPages = 2; // it will contain always on page more until we find that there is no answer anymore, then me make them equal
    }
    return self;
}

- (void) setReadOnly
{
    self.readOnly = YES;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // image for the navigator
    [self.navigationController.navigationBar troveboxStyle:NO];
    
    if ( self.readOnly){
        
        [self.navigationItem troveboxStyle:NSLocalizedString(@"Albums", @"Menu - title for Albums")  defaultButtons:NO viewController:nil menuViewController:nil];
        
        // button for create a new album
        UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", @"Add") style:UIBarButtonItemStylePlain target:self action:@selector(addNewAlbum)];
        self.navigationItem.rightBarButtonItem = customBarItem2;
        
        if ([self.albums count] == 0 ){
            // just load in case there is no album.
            // we do that to keep the past selection
            [self loadAlbums];
        }
        
    }else{
        [self.navigationItem troveboxStyle:NSLocalizedString(@"Albums", @"Menu - title for Albums") defaultButtons:YES viewController:self.viewDeckController menuViewController:(MenuViewController*) self.viewDeckController.leftController];
    }
    
    // title
    self.view.backgroundColor =  UIColorFromRGB(0XFAF3EF);
    self.tableView.separatorColor = UIColorFromRGB(0xC8BEA0);
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = UIColorFromRGB(0x3B2414);
    self.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(loadAlbums) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.readOnly == NO){
        [self.albums removeAllObjects];
        [self.tableView reloadData];
        
        // load all albums
        [self loadAlbums];
        
        self.totalPages=2;
        self.page=1;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
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
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    NSUInteger row = [indexPath row];
    
    Album *album = [self.albums objectAtIndex:row];
    cell.textLabel.text=album.name;
    
    if (self.readOnly == NO){
        // details quantity
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%d", album.quantity];
        cell.detailTextLabel.textColor = UIColorFromRGB(0xE6501E);
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        // check if it selected or not
        if(album.selected == YES)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (album.thumb != nil){
        // Here we use the new provided setImageWithURL: method to load the web image
        [cell.imageView setImageWithURL:[NSURL URLWithString:album.thumb]
                       placeholderImage:[UIImage imageNamed:@"empty_img.png"]];
    }else{
        [cell.imageView setImage:[UIImage imageNamed:@"empty_img.png"]];
    }
    
    
    if (self.totalPages){
        if ([self.albums count] - 1  == indexPath.row && self.page != self.totalPages){
            [self loadAlbums];
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the tag
    NSUInteger row = [indexPath row];
    Album *album = [self.albums objectAtIndex:row];
    
    if (self.readOnly == YES){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            album.selected = NO;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            album.selected = YES;
        }
    }else{
        if (album.quantity >0 ){
            // open the gallery with a tag that contains at least one picture.
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[GalleryViewController alloc]initWithAlbum:album]];
            self.viewDeckController.centerController = nav;
            [NSThread sleepForTimeInterval:(300+arc4random()%700)/1000000.0]; // mimic delay... not really necessary
        }
    }
}

#pragma mark
#pragma mark - Methods to get albums via json
- (void) loadAlbums
{
    // if there isn't netwok
    if ( [SharedAppDelegate internetActive] == NO ){
        // problem with internet, show message to user
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Please check your internet connection",@"") duration:5000];
        [alert showAlert];
    }else {
        //read the version of the system.
        // In the case of Albums we need to support version v1 and v2
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *serverDetails = [standardUserDefaults dictionaryForKey:kServerDetails];
        
        NSString *versionServer = @"v2";
        if ([serverDetails valueForKey:@"api"] != nil && [[serverDetails valueForKey:@"api"] isEqualToString:@"v1"]){
            // in this case if api is not null and the api is v1, we change the value
            // this will be used for the old installation of Trovebox
            versionServer = @"v1";
        }
        
        dispatch_queue_t loadAlbums = dispatch_queue_create("loadAlbums", NULL);
        dispatch_async(loadAlbums, ^{
            // call the method and get the details
            @try {
                // get factory for OpenPhoto Service
                WebService *service = [[WebService alloc] init];
                NSArray *result = [service loadAlbums:25 onPage:self.page version:versionServer];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([result class] != [NSNull class] && [result count] >0) {
                        // we may try to load more albums again
                        self.totalPages++;
                        self.page++;
                        
                        // check based on version
                        if ([versionServer isEqualToString:@"v1"]){
                            // in the v1, we just need to check if the result has
                            // more than one position in the array
                            [self loadAlbumsForV1:result];
                        }else if ([versionServer isEqualToString:@"v2"]){
                            // here the content will be always the same
                            // but we need to check the totalPages or totalRows
                            [self loadAlbumsForV2:result];
                        }
                        
                        // load data
                        [self.tableView reloadData];
                    }else{
                        self.totalPages = self.page;
                    }
                    
                    [self.refreshControl endRefreshing];
                });
            }@catch (NSException *exception) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:exception.description duration:5000];
                    [alert showAlert];
                    [self.refreshControl endRefreshing];
                });
            }
        });
    }
}

- (void) loadAlbumsForV1:(NSArray *) result
{
    // Loop through each entry in the dictionary and create an array Albums
    for (NSDictionary *albumDetails in result){
        [self processAlbumDetails:albumDetails];
    }
}

- (void) loadAlbumsForV2:(NSArray *) result
{
    // Loop through each entry in the dictionary and create an array Albums
    for (NSDictionary *albumDetails in result){
        
        // see if totalRows is null or totalPages = 0
        if ([albumDetails objectForKey:@"totalPages"] != nil &&
            [[albumDetails objectForKey:@"totalPages"] intValue] == 0){
            self.totalPages = self.page;
            break;
        }
        
        [self processAlbumDetails:albumDetails];
    }
}


- (void) processAlbumDetails:(NSDictionary *) albumDetails
{
    // tag name
    NSString *name = [albumDetails objectForKey:@"name"];
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // how many images
    NSString *qtd = [albumDetails objectForKey:@"count"];
    NSString *identification = [albumDetails objectForKey:@"id"];
    
    if ([qtd integerValue] >0 ){
        // first get the cover
        NSDictionary* cover = [albumDetails objectForKey:@"cover"];
        NSString *size;
        if ([DisplayUtilities isIPad])
            size = @"photo200x200xCR";
        else
            size = @"photo100x100xCR";
        NSArray *pathCover = [cover objectForKey:size];
        
        // create an album and add to the list of albums
        Album *album = [[Album alloc]initWithAlbumName:name Quantity:[qtd integerValue] Identification:identification AlbumImageUrl:[pathCover objectAtIndex:0]];
        
        [self.albums addObject:album];
    }else if (self.readOnly){
        // in this case add just with the name and count
        Album *album = [[Album alloc]initWithAlbumName:name Quantity:0 Identification:identification AlbumImageUrl:nil];
        [self.albums addObject:album];
    }
}
- (void) addNewAlbum
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Adding new album");
#endif
    
    TSAlertView* av = [[TSAlertView alloc] initWithTitle:NSLocalizedString(@"Enter new album name",@"Album screen - create a new album") message:nil delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                       otherButtonTitles:NSLocalizedString(@"OK",nil),nil];
    av.style = TSAlertViewStyleInput;
    [av show];
}

// after animation
- (void) alertView: (TSAlertView *) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex
{
    // cancel
    if( buttonIndex == 0 || alertView.inputTextField.text == nil || alertView.inputTextField.text.length==0)
        return;
    
    // add the new tag in the list and select it
    Album *album = [[Album alloc] initWithAlbumName:alertView.inputTextField.text];
    
    MBProgressHUD *hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Creating",@"Creating Album");
    
    dispatch_queue_t createAlbum = dispatch_queue_create("createAlbum", NULL);
    dispatch_async(createAlbum, ^{
        @try {
            // get factory for Trovebox Service
            WebService *service = [[WebService alloc] init];
            NSString *identification = [service createAlbum:album];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                album.identification = identification;
                album.selected = YES;
                [self.albums addObject:album];
                [self.tableView reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }@catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:exception.description duration:5000];
                [alert showAlert];
            });
        }
    });
}

-(NSString*) getSelectedAlbumsIdentification
{
    NSMutableString *result = [NSMutableString string];
    NSArray *selectedAlbums = [self getSelectedAlbums];
    int counter = 1;
    
    if (selectedAlbums != nil && [selectedAlbums count]>0){
        for (Album* album in selectedAlbums) {
            [result appendFormat:@"%@",album.identification];
            
            // add the ,
            if ( counter < [selectedAlbums count]){
                [result appendFormat:@", "];
            }
            
            counter++;
        }
    }
    
    return result;
}

- (NSArray *) getSelectedAlbums
{
    NSMutableArray *array = [NSMutableArray array];
    for (Album* album in self.albums) {
        if (album.selected == YES){
            [array addObject:album];
        }
    }
    
    return array;
}

@end
//
//  AlbumViewController.m
//  Photo
//
//  Created by Patrick Santana on 09/10/12.
//  Copyright 2012 Photo
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

// to avoid multiples loading
@property (nonatomic) BOOL isLoading;
//used for create new albums
@property (nonatomic) BOOL readOnly;

@end

@implementation AlbumViewController

@synthesize albums = _albums, isLoading = _isLoading, readOnly=_readOnly;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // initialize the object albums
        self.albums = [NSMutableArray array];
        
        // is loading albums
        self.isLoading = NO;
        
        self.readOnly = NO;
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
       
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *buttonImage = [UIImage imageNamed:@"back.png"] ;
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
        [button addTarget:self action:@selector(OnClick_btnBack:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = customBarItem;
        
        // button for create a new album
        UIButton *buttonAdd = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *buttonImageAdd = [UIImage imageNamed:@"add.png"] ;
        [buttonAdd setImage:buttonImageAdd forState:UIControlStateNormal];
        buttonAdd.frame = CGRectMake(0, 0, buttonImageAdd.size.width, buttonImageAdd.size.height);
        [buttonAdd addTarget:self action:@selector(addNewAlbum) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *customBarItemAdd = [[UIBarButtonItem alloc] initWithCustomView:buttonAdd];
        self.navigationItem.rightBarButtonItem = customBarItemAdd;
        
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
}


-(IBAction)OnClick_btnBack:(id)sender  {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.readOnly == NO || [self.albums count] == 0 ){
        // load all albums
        [self loadAlbums];
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
    
    if (self.isLoading == NO){
        self.isLoading = YES;
        // if there isn't netwok
        if ( [SharedAppDelegate internetActive] == NO ){
            // problem with internet, show message to user
            PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Please check your internet connection",@"") duration:5000];
            [alert showAlert];
            
            self.isLoading = NO;
        }else {
            MBProgressHUD *hud;
            
            if ( self.readOnly){
                hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            }    else{
                hud = [MBProgressHUD showHUDAddedTo:self.viewDeckController.view animated:YES];
            }
            hud.labelText = NSLocalizedString(@"Loading",nil);
            
            dispatch_queue_t loadAlbums = dispatch_queue_create("loadAlbums", NULL);
            dispatch_async(loadAlbums, ^{
                // call the method and get the details
                @try {
                    // get factory for OpenPhoto Service
                    WebService *service = [[WebService alloc] init];
                    NSArray *result = [service loadAlbums:25];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.albums removeAllObjects];
                        if ([result class] != [NSNull class]) {
                            // Loop through each entry in the dictionary and create an array Albums
                            for (NSDictionary *albumDetails in result){
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
                            }}
                        
                        [self.tableView reloadData];
                        if ( self.readOnly){
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        }else{
                            [MBProgressHUD hideHUDForView:self.viewDeckController.view animated:YES];
                        }
                        self.isLoading = NO;
                        
                    });
                }@catch (NSException *exception) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ( self.readOnly){
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        }else{
                            [MBProgressHUD hideHUDForView:self.viewDeckController.view animated:YES];
                        }
                        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:exception.description duration:5000];
                        [alert showAlert];
                        self.isLoading = NO;
                    });
                }
            });
            dispatch_release(loadAlbums);
        }
    }
}

-(void) addNewAlbum
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
    
    MBProgressHUD *hud;
    
    if ( self.readOnly){
        hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }    else{
        hud = [MBProgressHUD showHUDAddedTo:self.viewDeckController.view animated:YES];
    }
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
                if ( self.readOnly){
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }else{
                    [MBProgressHUD hideHUDForView:self.viewDeckController.view animated:YES];
                }
                self.isLoading = NO;
            });
        }@catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( self.readOnly){
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }else{
                    [MBProgressHUD hideHUDForView:self.viewDeckController.view animated:YES];
                }
                
                PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:exception.description duration:5000];
                [alert showAlert];
                self.isLoading = NO;
            });
        }
    });
    dispatch_release(createAlbum);
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
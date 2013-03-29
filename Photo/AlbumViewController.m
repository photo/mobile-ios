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

// to avoid multiples loading
@property (nonatomic) BOOL isLoading;

@end

@implementation AlbumViewController

@synthesize albums = _albums;
@synthesize isLoading = _isLoading;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // initialize the object albums
        self.albums = [NSMutableArray array];
        
        // is loading albums
        self.isLoading = NO;
    }
    return self;
}
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // menu
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButtonImage = [UIImage imageNamed:@"button-navigation-menu.png"] ;
    [leftButton setImage:leftButtonImage forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(0, 0, leftButtonImage.size.width, leftButtonImage.size.height);
    [leftButton addTarget:self.viewDeckController  action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customLeftButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = customLeftButton;
    
    // camera
    UIButton *buttonRight = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonRightImage = [UIImage imageNamed:@"button-navigation-camera.png"] ;
    [buttonRight setImage:buttonRightImage forState:UIControlStateNormal];
    buttonRight.frame = CGRectMake(0, 0, buttonRightImage.size.width, buttonRightImage.size.height);
    [buttonRight addTarget:self action:@selector(openCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customRightButton = [[UIBarButtonItem alloc] initWithCustomView:buttonRight];
    self.navigationItem.rightBarButtonItem = customRightButton;
    
    // title
    self.navigationItem.title = NSLocalizedString(@"Albums", @"Menu - title for Albums");
    
    UIImage *backgroundImage = [UIImage imageNamed:@"Background.png"];
    
    // color separator
    self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:backgroundImage];
    self.tableView.separatorColor = UIColorFromRGB(0xC8BEA0);
    
    // image for the navigator
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]){
        //iOS >=5.0
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"appbar_empty.png"] forBarMetrics:UIBarMetricsDefault];
    }else{
        UIImageView *imageView = (UIImageView *)[self.navigationController.navigationBar viewWithTag:6183746];
        if (imageView == nil)
        {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appbar_empty.png"]];
            [imageView setTag:6183746];
            [self.navigationController.navigationBar insertSubview:imageView atIndex:0];
        }
    }
}

- (void) openCamera:(id) sender
{
    [(MenuViewController*)self.viewDeckController.leftController openCamera:sender];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // load all albums
    [self loadAlbums];
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
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%d", album.quantity];
    cell.detailTextLabel.textColor = UIColorFromRGB(0xE6501E);

    // Here we use the new provided setImageWithURL: method to load the web image
    [cell.imageView setImageWithURL:[NSURL URLWithString:album.thumb]
                   placeholderImage:[UIImage imageNamed:@"empty_img.png"]];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the tag
    NSUInteger row = [indexPath row];
    Album *album = [self.albums objectAtIndex:row];
    
    if (album.quantity >0 ){
        // open the gallery with a tag that contains at least one picture.
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[GalleryViewController alloc]initWithAlbum:album]];
        self.viewDeckController.centerController = nav;
        [NSThread sleepForTimeInterval:(300+arc4random()%700)/1000000.0]; // mimic delay... not really necessary
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
            PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:@"Failed! Check your internet connection" duration:5000];
            [alert showAlert];
            
            self.isLoading = NO;
        }else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewDeckController.view animated:YES];
            hud.labelText = @"Loading";
            
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
                            }}
                        
                        [self.tableView reloadData];
                        [MBProgressHUD hideHUDForView:self.viewDeckController.view animated:YES];
                        self.isLoading = NO;
                        
                    });
                }@catch (NSException *exception) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
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
@end
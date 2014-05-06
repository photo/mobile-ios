//
//  GalleryViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 30/10/12.
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

#import "GalleryViewController.h"

@interface GalleryViewController ()
- (void) loadPhotos:(UIRefreshControl *)refreshControl;

// for loading page
@property (nonatomic) NSInteger page;
@property (nonatomic) NSInteger totalPages;

// for albums or tags
@property (nonatomic,strong) Album *album;
@property (nonatomic,strong) Tag *tag;
@end

@implementation GalleryViewController
@synthesize photos=_photos, page=_page, totalPages=_totalPages,  album=_album,  tag=_tag, friend=_friend;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.photos = [NSMutableArray array];
        self.page = 1;
    }
    return self;
}

- (id) initWithTag:(Tag *) tag
{
    self = [self init];
    if (self){
        self.tag = tag;
    }
    
    return self;
}

- (id) initWithAlbum:(Album *) album
{
    self = [self init];
    if (self){
        self.album = album;
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor =  UIColorFromRGB(0XFAF3EF);
    
    // image for the navigator
    [self.navigationController.navigationBar troveboxStyle:NO];
    
    if (self.friend && self.album){
        // let use to download album
        [self.navigationItem troveboxStyle:NSLocalizedString(@"Gallery", @"Menu - title for Gallery")  defaultButtons:NO viewController:nil menuViewController:nil];
        
        // menu
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *leftButtonImage = [UIImage imageNamed:@"button-navigation-menu.png"] ;
        [leftButton setImage:leftButtonImage forState:UIControlStateNormal];
        leftButton.frame = CGRectMake(0, 0, leftButtonImage.size.width, leftButtonImage.size.height);
        [leftButton addTarget:self.viewDeckController  action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *customLeftButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        self.navigationItem.leftBarButtonItem = customLeftButton;
        
        // button Logout
        UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Copy", @"Copy in the Album") style:UIBarButtonItemStylePlain target:self action:@selector(copyImages)];
        self.navigationItem.rightBarButtonItem = customBarItem;
        
        
    }else{
        // title and buttons
        [self.navigationItem troveboxStyle:NSLocalizedString(@"Gallery", @"Menu - title for Gallery") defaultButtons:YES viewController:self.viewDeckController menuViewController:(MenuViewController*) self.viewDeckController.leftController];
    }
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = UIColorFromRGB(0x3B2414);
    [refreshControl addTarget:self action:@selector(loadPhotos:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:refreshControl];
}

-(void) copyImages{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Please confirm you’d like to download your friend’s album to your NAS",@"Message to Please confirm you’d like to download your friend’s photo to your NAS") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"") otherButtonTitles:NSLocalizedString(@"Copy",@""),nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1){
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Add all images in the database");
#endif
        // limit to max 20;
        int i = 0;
        for ( MWPhoto *photo in self.photos){
            if (i <20){
                PhotoFriendUploader *upload = [[PhotoFriendUploader alloc]init];
                [upload loadDataAndSaveEntityUrl:photo.url];
                i++;
            }else{
                break;
            }
        }
        
        // also lets save the Managed Context
        NSError *saveError = nil;
        if (![[SharedAppDelegate managedObjectContext] save:&saveError]){
            NSLog(@"Error to save context = %@",[saveError localizedDescription]);
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.page = 1;
    self.totalPages = 0;
    // load photos
    [self loadPhotos:nil];
}

#pragma mark - Rotation

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

#pragma mark - QuiltViewControllerDataSource
- (UIImage *)imageAtIndexPath:(NSIndexPath *)indexPath {
    return [UIImage imageNamed:[self.photos objectAtIndex:indexPath.row]];
}

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return [self.photos count];
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    TMPhotoQuiltViewCell *cell = (TMPhotoQuiltViewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"PhotoCell"];
    if (!cell) {
        cell = [[TMPhotoQuiltViewCell alloc] initWithReuseIdentifier:@"PhotoCell"];
    }
    
    MWPhoto *photo = [self.photos objectAtIndex:indexPath.row];
    [cell.photoView setImageWithURL:[NSURL URLWithString:photo.thumbUrl]
                   placeholderImage:nil
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                              if (error){
                                  PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Couldn't download the image",nil) duration:5000];
                                  [alert showAlert];
                              }
                          }];
    
    
    // check if it is the last cell
    if (self.totalPages){
        if ([self.photos count] - 1  == indexPath.row && self.page <= self.totalPages){
            [self loadPhotos:nil];
        }
    }
    
    return cell;
}

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    // Create & present browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    // Set options
    browser.wantsFullScreenLayout = YES;
    
    // check if user is type GROUP
    // if yes, he should not have access to actions
    NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:kTroveboxTypeUser];
    if (type && [type isEqualToString:@"group"]){
        browser.displayActionButton = NO;
    }else{
        browser.displayActionButton = YES;
    }
    
    [browser setCurrentPhotoIndex:indexPath.row];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:browser];
    
    // Present
    [self presentViewController:nav animated:NO completion:nil];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (BOOL) isPhotoFromFriend{
    return (self.friend != nil);
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count){
        return [self.photos objectAtIndex:index];
    }
    
    return nil;
}


#pragma mark - TMQuiltViewDelegate

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView {
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft
        || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        
        // is iPad
        if ([DisplayUtilities isIPad]){
            return 6;
        }
        
        return 3;
    } else {
        // is iPad
        if ([DisplayUtilities isIPad]){
            return 4;
        }
        
        return 2;
    }
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    MWPhoto *photo = [self.photos objectAtIndex:indexPath.row];
    return [photo.thumbHeight integerValue];
}

-(void) loadPhotos:(UIRefreshControl *)refreshControl
{
    // if there isn't netwok
    if ( [SharedAppDelegate internetActive] == NO ){
        // problem with internet, show message to user
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Please check your internet connection",@"") duration:5000];
        [alert showAlert];
    }else {
        dispatch_queue_t loadPhotos = dispatch_queue_create("loadPhotos", NULL);
        dispatch_async(loadPhotos, ^{
            // call the method and get the details
            @try {
                // get factory for Service
                WebService *service = [[WebService alloc] init];
                NSArray *result;
                
                // if user is refreshing that means we must load the initial data
                if (refreshControl != nil){
                    self.page = 1;
                    self.totalPages = 0;
                }
                
                if (self.friend) {
                    if (self.album){
                        result = [service loadGallery:50 onPage:self.page++ album:self.album forSite:self.friend.host];
                    }else{
                        result = [service loadGallery:50 onPage:self.page++ forSite:self.friend.host];
                    }
                }else{
                    if (self.album){
                        result = [service loadGallery:50 onPage:self.page++ album:self.album];
                    }else if (self.tag){
                        result = [service loadGallery:50 onPage:self.page++ tag:self.tag];
                    }else{
                        result = [service loadGallery:50 onPage:self.page++];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([result class] != [NSNull class]) {
                        
                        if ( self.page == 2 ){
                            // first time loading
                            [self.photos removeAllObjects];
                        }
                        
                        // Loop through each entry in the dictionary and create an array of photos
                        for (NSDictionary *photoDetails in result){
                            
                            // get totalPages
                            if (!self.totalPages){
                                self.totalPages = [[photoDetails objectForKey:@"totalPages"] doubleValue];
                            }
                            
                            MWPhoto *photo = [MWPhoto photoWithServerInfo:photoDetails];
                            if (photo != nil){
                                [self.photos addObject:photo];
                            }
                        }
                    }
                    
                    [self.quiltView reloadData];
                    [refreshControl endRefreshing];
                });
            }@catch (NSException *exception) {
                dispatch_async(dispatch_get_main_queue(), ^{
#ifdef DEVELOPMENT_ENABLED
                    NSLog(@"Exception %@",exception.description);
#endif
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:exception.description duration:5000];
                    [alert showAlert];
                    [refreshControl endRefreshing];
                });
            }
        });
    }
}
@end

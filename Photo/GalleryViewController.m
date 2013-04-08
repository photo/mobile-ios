//
//  GalleryViewController.m
//  Photo
//
//  Created by Patrick Santana on 30/10/12.
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



#import "GalleryViewController.h"
#import "UINavigationBar+Trovebox.h"

@interface GalleryViewController ()
- (void) loadPhotos;

// to avoid multiples loading
@property (nonatomic) BOOL isLoading;
// for loading page
@property (nonatomic) NSInteger page;
@property (nonatomic) NSInteger totalPages;

// for albums or tags
@property (nonatomic,strong) Album *album;
@property (nonatomic,strong) Tag *tag;
@end

@implementation GalleryViewController
@synthesize photos=_photos;
@synthesize isLoading=_isLoading;
@synthesize page=_page;
@synthesize totalPages=_totalPages;
@synthesize album=_album;
@synthesize tag=_tag;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.photos = [NSMutableArray array];
        self.isLoading = NO;
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
    
    // image for the navigator
    [self.navigationController.navigationBar troveboxStyle];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"Background.png"];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:backgroundImage];
    // title
    self.navigationItem.title = NSLocalizedString(@"Gallery", @"Menu - title for Gallery");
    
    // quilt configuration
    self.quiltView.backgroundColor =  [[UIColor alloc] initWithPatternImage:backgroundImage];
}

- (void) openCamera:(id) sender
{
    [(MenuViewController*)self.viewDeckController.leftController openCamera:sender];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // load photos
    [self loadPhotos];
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
    
    WebPhoto *photo = [self.photos objectAtIndex:indexPath.row];
    [cell.photoView setImageWithURL:[NSURL URLWithString:photo.thumbUrl]
                   placeholderImage:nil
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                              if (error){
                                  PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:@"Couldn't download the image" duration:5000];
                                  [alert showAlert];
                              }
                          }];
    
    
    // check if it is the last cell
    if (self.totalPages){
        if ([self.photos count] - 1  == indexPath.row && self.page <= self.totalPages){
            [self loadPhotos];
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
    browser.displayActionButton = YES;
    [browser setInitialPageIndex:indexPath.row]; 
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:browser];

    // Present
    [self presentModalViewController:nav animated:NO];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count){
        WebPhoto *photo =  [self.photos objectAtIndex:index];
        return photo.mwphoto;
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
    WebPhoto *photo = [self.photos objectAtIndex:indexPath.row];
    
    return [photo.thumbHeight integerValue];
}

-(void) loadPhotos
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
            
            dispatch_queue_t loadPhotos = dispatch_queue_create("loadPhotos", NULL);
            dispatch_async(loadPhotos, ^{
                // call the method and get the details
                @try {
                    // get factory for Service
                    WebService *service = [[WebService alloc] init];
                    NSArray *result;
                    
                    if (self.album){
                        result = [service loadGallery:50 onPage:self.page++ album:self.album];
                    }else if (self.tag){
                        result = [service loadGallery:50 onPage:self.page++ tag:self.tag];
                    }else{
                        result = [service loadGallery:50 onPage:self.page++];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([result class] != [NSNull class]) {
                            // Loop through each entry in the dictionary and create an array of photos
                            for (NSDictionary *photoDetails in result){
                                
                                // get totalPages
                                if (!self.totalPages){
                                    self.totalPages = [[photoDetails objectForKey:@"totalPages"] doubleValue];
                                }
                                
                                WebPhoto *photo = [WebPhoto photoWithServerInfo:photoDetails];
                                [self.photos addObject:photo];
                            }
                        }
                        
                        [MBProgressHUD hideHUDForView:self.viewDeckController.view animated:YES];
                        self.isLoading = NO;
                        [self.quiltView reloadData];
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
            dispatch_release(loadPhotos);
        }
    }    
}
@end

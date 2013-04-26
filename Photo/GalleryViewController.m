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
    
    self.view.backgroundColor =  UIColorFromRGB(0XFAF3EF);

    // image for the navigator
    [self.navigationController.navigationBar troveboxStyle:NO];
    
    // title and buttons
    [self.navigationItem troveboxStyle:NSLocalizedString(@"Gallery", @"Menu - title for Gallery") defaultButtons:YES viewController:self.viewDeckController menuViewController:(MenuViewController*) self.viewDeckController.leftController];
    
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
    self.totalPages = nil;
    // load photos
    [self loadPhotos];
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
    
    WebPhoto *photo = [self.photos objectAtIndex:indexPath.row];
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
            PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Please check your internet connection",@"") duration:5000];
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
                            
                            if ( self.page == 2 ){
                                // first time loadin
                                [self.photos removeAllObjects];
                            }
                            
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

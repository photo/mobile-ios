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

const NSInteger kNumberOfCells = 10;

@interface GalleryViewController ()
- (void) loadPhotos;

// to avoid multiples loading
@property (nonatomic) BOOL isLoading;

@end

@implementation GalleryViewController
@synthesize photos=_photos;
@synthesize isLoading=_isLoading;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.photos = [NSMutableArray array];
        self.isLoading = NO;
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
    
    UIImage *backgroundImage = [UIImage imageNamed:@"Background.png"];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:backgroundImage];
    // title
    self.navigationItem.title = NSLocalizedString(@"Gallery", @"Menu - title for Gallery");
    
    
    
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
    
    NSMutableArray *imageNames = [NSMutableArray array];
    for(int i = 0; i < kNumberOfCells; i++) {
        [imageNames addObject:[NSString stringWithFormat:@"%d.jpeg", i % 10 + 1]];
    }
    self.photos = imageNames;
    
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
    
    cell.photoView.image = [self imageAtIndexPath:indexPath];
    [cell.photoView setImageWithURL:[NSURL URLWithString:@"http://ps.openphoto.me.s3.amazonaws.com/custom/201303/3244B2B0-0014-4708-9935-CB6CACE257E3-898dc6_870x870.jpg"]
                   placeholderImage:nil
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                              if (error){
                                  PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:@"Couldn't download the image" duration:5000];
                                  [alert showAlert];
                              }
                          }];
    
    return cell;
}

#pragma mark - TMQuiltViewDelegate

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView {
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft
        || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        return 3;
    } else {
        return 2;
    }
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    return [self imageAtIndexPath:indexPath].size.height / [self quiltViewNumberOfColumns:quiltView];
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
                    NSArray *result = [service loadGallery:50 onPage:1];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([result class] != [NSNull class]) {
                            // Loop through each entry in the dictionary and create an array of photos
                            
                            for (NSDictionary *photoDetails in result){
                                [Photo photoWithServerInfo:photoDetails inManagedObjectContext:[SharedAppDelegate managedObjectContext]];
                            }}
                        
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
            dispatch_release(loadPhotos);
        }
    }
    
}
@end

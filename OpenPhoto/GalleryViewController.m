//
//  GalleryViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 11/07/11.
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

#import "GalleryViewController.h"

@interface GalleryViewController()
- (void) loadImages;
@property (nonatomic, retain) TagViewController *tagController;
@property (nonatomic) BOOL showBack;

// to avoid multiples loading
@property (nonatomic) BOOL isLoading;

// update the images
@property (nonatomic) BOOL needsUpdate;

@end

@implementation GalleryViewController
@synthesize service=_service, tagName=_tagName;
@synthesize tagController=_tagController;
@synthesize showBack = _showBack;
@synthesize isLoading = _isLoading;
@synthesize needsUpdate = _needsUpdate;

- (id)init{
    self = [super init];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor blackColor];
        self.tabBarItem.image=[UIImage imageNamed:@"tab-gallery.png"];
        self.tabBarItem.title=@"Gallery";
        self.title=@"Gallery";
        self.hidesBottomBarWhenPushed = NO;
        self.wantsFullScreenLayout = YES;
        self.statusBarStyle = UIStatusBarStyleBlackOpaque;
        self.tableView.backgroundColor = [[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Background.png"]] autorelease];
        
        
        // create service and the delegate
        WebService *web = [[WebService alloc]init];
        self.service = web;
        [self.service setDelegate:self];
        [web release];
        
        NSArray *photos = [GalleryPhotos getGalleryPhotosInManagedObjectContext:[AppDelegate managedObjectContext]];
        
        if (photos == nil || [photos count] == 0){
            self.photoSource = [[[PhotoSource alloc]
                                 initWithTitle:@"Gallery"
                                 photos:nil size:0 tag:nil] autorelease];
        }else {
            self.photoSource = [[[PhotoSource alloc]
                                 initWithTitle:@"Gallery"
                                 photos:photos size:[photos count] tag:nil] autorelease];
        }
        
        self.tagController = [[[TagViewController alloc] init] autorelease];
        
        // show back button and loading control
        self.showBack = YES;
        self.isLoading = NO;
        self.needsUpdate = YES;
        
        // clean table when log out    
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(eventHandler:)
                                                     name:kNotificationLoginNeeded       
                                                   object:nil ];
        
        // needs update in screen  
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(eventHandler:)
                                                     name:kNotificationNeededsUpdate    
                                                   object:nil ];
    }
    return self;
}

- (id) initWithTagName:(NSString*) tag{
    self = [self init];
    if (self) {
        self.tagName = tag;
        self.photoSource = [[[PhotoSource alloc]
                             initWithTitle:@"Gallery"
                             photos:nil size:0 tag:nil] autorelease];
        self.showBack = NO;
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadImages)];          
    self.navigationItem.rightBarButtonItem = refreshButton;
    [refreshButton release];
    
    if (self.showBack){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *buttonImage = [UIImage imageNamed:@"gallery-show-tags.png"] ;
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
        [button addTarget:self action:@selector(loadTags) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button]; 
        self.navigationItem.leftBarButtonItem = customBarItem;
        [customBarItem release];
    }
    
    if (self.needsUpdate){    
        [self loadImages];
        self.needsUpdate = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

- (void) loadTags{
    [self.navigationController pushViewController:self.tagController animated:YES];
}

- (void) loadImages{
    if (self.isLoading == NO){
        self.isLoading = YES;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"Loading";
        
        
        if (self.tagName != nil){
            [self.service loadGallery:24 withTag:self.tagName onPage:1];
        }else{
            [self.service loadGallery:24 onPage:1];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set the tile of the table
    self.title=@"Gallery";     
}

// delegate
-(void) receivedResponse:(NSDictionary *)response{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.isLoading = NO;
    
    // check if message is valid
    if (![WebService isMessageValid:response]){
        NSString* message = [WebService getResponseMessage:response];
        NSLog(@"Invalid response = %@",message);
        
        // show alert to user
        OpenPhotoAlertView *alert = [[OpenPhotoAlertView alloc] initWithMessage:message duration:5000];
        [alert showAlert];
        [alert release];
        
        return;
    }
    
    NSArray *responsePhotos = [response objectForKey:@"result"] ;
    
    // result can be null
    if ([responsePhotos class] != [NSNull class]) {
        
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        BOOL first=YES;
        int totalRows=0;
        
        // Load in core data
        [GalleryPhotos getGalleryPhotosFromOpenPhotoService:responsePhotos inManagedObjectContext:[AppDelegate managedObjectContext]]; 
        
        for (NSDictionary *photo in responsePhotos){
            
            // for the first, get how many pictures is in the server
            if (first == YES){
                totalRows = [[photo objectForKey:@"totalRows"] intValue];
                first = NO;
            }
            
            // Get title of the image
            NSString *title = [photo objectForKey:@"title"];
            if ([title class] == [NSNull class])
                title = @"";
            
#ifdef DEVELOPMENT_ENABLED      
            NSLog(@"Photo Thumb url [%@] with title [%@]", [photo objectForKey:@"path200x200"], title);
#endif            
            
            float width = [[photo objectForKey:@"width"] floatValue];
            float height = [[photo objectForKey:@"height"] floatValue];
            
            // calculate the real size of the image. It will keep the aspect ratio.
            float realWidth = 0;
            float realHeight = 0;
            
            if(width/height >= 1) { 
                // portrait or square
                realWidth = 640;
                realHeight = height/width*640;
            } else { 
                // landscape
                realHeight = 960;
                realWidth = width/height*960;
            }
            
            [photos addObject: [[[Photo alloc]
                                 initWithURL:[NSString stringWithFormat:@"%@", [photo objectForKey:@"path640x960"]]
                                 smallURL:[NSString stringWithFormat:@"%@",[photo objectForKey:@"path200x200"]] 
                                 size:CGSizeMake(realWidth, realHeight) caption:title page:[NSString stringWithFormat:@"%@",[photo objectForKey:@"url"]] ] autorelease]];
        } 
        
        
        if (totalRows != 0){
            self.photoSource = [[[PhotoSource alloc]
                                 initWithTitle:@"Gallery"
                                 photos:photos size:totalRows tag:self.tagName] autorelease] ;
        }
        
        [photos release];
    }
    
    
#ifdef TEST_FLIGHT_ENABLED
    [TestFlight passCheckpoint:@"Gallery Loaded"];
#endif
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}

- (void) notifyUserNoInternet{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.isLoading = NO;
    
    // problem with internet, show message to user    
    OpenPhotoAlertView *alert = [[OpenPhotoAlertView alloc] initWithMessage:@"Failed! Check your internet connection" duration:5000];
    [alert showAlert];
    [alert release];
}


- (void) eventHandler: (NSNotification *) notification{
#ifdef DEVELOPMENT_ENABLED    
    NSLog(@"###### Event triggered: %@", notification);
#endif
    
    if ([notification.name isEqualToString:kNotificationLoginNeeded]){
        self.photoSource = [[[PhotoSource alloc]
                             initWithTitle:@"Gallery"
                             photos:nil size:0 tag:nil] autorelease];
    }else if ([notification.name isEqualToString:kNotificationNeededsUpdate]){
        self.needsUpdate = YES;
    }
}


- (void) dealloc {
    [_service release];
    [_tagName release];
    [_tagController release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end

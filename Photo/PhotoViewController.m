//
//  PhotoViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 29/07/11.
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

#import "PhotoViewController.h"

@interface PhotoViewController()
- (void) switchedFacebook;

- (void) switchedTwitter;

- (void) saveEntityUploadDate:(NSDate *) date
                shareFacebook:(NSNumber *) facebook
                 shareTwitter:(NSNumber *) twitter
                        image:(NSData *) image
                   permission:(NSNumber *) permission
                         tags:(NSString *) tags
                       albums:(NSString *) albums
                        title:(NSString *) title
                          url:(NSURL *) url
                     groupUrl:(NSString *) urlGroup;

- (void) loadDataAndSaveEntityUploadDate:(NSDate *) date
                           shareFacebook:(NSNumber *) facebook
                            shareTwitter:(NSNumber *) twitter
                              permission:(NSNumber *) permission
                                    tags:(NSString *) tags
                                  albums:(NSString *) albums
                                   title:(NSString *) title
                                     url:(NSURL *) url
                                groupUrl:(NSString *) urlGroup;

- (void)upload:(id)sender;

@end

@implementation PhotoViewController

@synthesize detailsPictureTable=_detailsPictureTable;
@synthesize titleTextField=_titleTextField, permissionPicture=_permissionPicture, shareFacebook=_shareFacebook, shareTwitter=_shareTwitter;
@synthesize tagController=_tagController, albumController=_albumController;

@synthesize image= _image;
@synthesize images = _images;

// assets
@synthesize assetsLibrary = _assetsLibrary;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL *) imageFromCamera
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        self.image = imageFromCamera;
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        // initialization of tag controller
        self.tagController = [[TagViewController alloc] init];
        [self.tagController setReadOnly];
        
        // initialization of algum controller
        self.albumController = [[AlbumViewController alloc] init];
        [self.albumController setReadOnly];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil images:(NSArray *) imagesFromSync
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        self.images = imagesFromSync;
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        // how many images we need to process?
        if (self.images){
            // if there is only one, treat it as a camera image, so user will be able to edit
            if ([self.images count] == 1){
                self.image = [self.images lastObject];
            }
        }
        
        // initialization of tag controller
        self.tagController = [[TagViewController alloc] init];
        [self.tagController setReadOnly];
        
        // initialization of algum controller
        self.albumController = [[AlbumViewController alloc] init];
        [self.albumController setReadOnly];
    }
    return self;
}


#pragma mark - View lifecycle
- (void)viewDidLoad{
    [super viewDidLoad];
    self.trackedViewName = @"Upload Screen";
    self.title = @"Upload";
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (self.images){
        self.detailsPictureTable.frame = CGRectMake(self.detailsPictureTable.frame.origin.x,self.detailsPictureTable.frame.origin.y - 40, self.detailsPictureTable.frame.size.width,self.detailsPictureTable.frame.size.height+40);
        // come from sync, change the default back button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *buttonImage = [UIImage imageNamed:@"back.png"] ;
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
        [button addTarget:self action:@selector(OnClick_btnBack:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = customBarItem;
    }else{
        // if user wants to cancel the upload
        // it should be just in the case of snapshot
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *buttonImage = [UIImage imageNamed:@"close_camera.png"] ;
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
        [button addTarget:self action:@selector(cancelUploadButton) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = customBarItem;
        
    }
    
    // button to done
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [UIImage imageNamed:@"done.png"] ;
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:self action:@selector(upload:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = customBarItem;
    
    self.detailsPictureTable.backgroundColor =  UIColorFromRGB(0XFAF3EF);
}


- (void) cancelUploadButton{
    [self dismissModalViewControllerAnimated:YES];
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"UI Action"
                                                      withAction:@"buttonPress"
                                                       withLabel:@"Cancel Upload"
                                                       withValue:nil];
}

-(IBAction)OnClick_btnBack:(id)sender  {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload{
    [self setLabelLimitUpload:nil];
    [super viewDidUnload];
    [self setDetailsPictureTable:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([SharedAppDelegate isProUser]){
        self.labelLimitUpload.hidden = TRUE;
    }else{
        self.labelLimitUpload.hidden = FALSE;
        
        // set lable for the limit
        NSString *message;
        if ([SharedAppDelegate limitFreeUser] == 1){
            message = NSLocalizedString(@"You can upload one more photo this month",@"Message limit - one more photo");
        }else if([SharedAppDelegate limitFreeUser] > 1){
            message = NSLocalizedString(([NSString stringWithFormat:@"You can upload %d more photos this month", [SharedAppDelegate limitFreeUser]]), @"Message limit - n more photos");
        }else{
            message = NSLocalizedString(([NSString stringWithFormat:@"You've reached your monthly limit of %d photos", [SharedAppDelegate limitAllowed]]), @"Message when limit is reached on upload screen");
        }
        
        self.labelLimitUpload.text = message;
        
        if ([SharedAppDelegate limitFreeUser] == 0){
            // limit reached,
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Limit reached", @"Upload - text in the upload form for limits")
                                                            message: NSLocalizedString(([NSString stringWithFormat:@"You've reached your monthly limit of %d photos. Upgrade today for an unlimited Pro account.", [SharedAppDelegate limitAllowed]]), @"Message when limit is reached")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                                  otherButtonTitles:NSLocalizedString(@"Upgrade",nil), nil];
            [alert show];
            //disable button
            self.navigationItem.rightBarButtonItem.enabled = FALSE;
        }
    }
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    NSUInteger row = [indexPath row];
    switch (row) {
        case 0:
            // title
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierTitle];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierTitle];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                self.titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(17 , 13, 260, 21)];
                self.titleTextField.adjustsFontSizeToFitWidth = YES;
                self.titleTextField.textColor = UIColorFromRGB(0x8C7B73);
                
                self.titleTextField.placeholder = NSLocalizedString(@"title",@"Upload - inside text input");
                self.titleTextField.keyboardType = UIKeyboardTypeDefault;
                self.titleTextField.returnKeyType = UIReturnKeyNext;
                self.titleTextField.delegate = self;
                [cell addSubview:self.titleTextField];
            }
            break;
        case 1:
            // tags
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierTags];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierTags];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=NSLocalizedString(@"Tags",@"Upload - tags");
            // customised disclosure button
            [cell setAccessoryView:[self makeDetailDisclosureButton]];
            break;
            
        case 2:
            // albums
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierAlbums];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierAlbums];
            }
            
            cell.textLabel.text=NSLocalizedString(@"Albums",@"Upload - Albums");
            // customised disclosure button
            [cell setAccessoryView:[self makeDetailDisclosureButton]];
            break;
            
        case 3:
            // private flag
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierPrivate];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierPrivate];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=NSLocalizedString(@"Private",@"Upload - Private");
            self.permissionPicture = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = self.permissionPicture;
            
            if([self.permissionPicture respondsToSelector:@selector(setOnTintColor:)]){
                //iOS 5.0
                [self.permissionPicture setOnTintColor:UIColorFromRGB(0xEFC005)];
            }
            
            // get from user configuration if pictures should be private or not
            [(UISwitch *)cell.accessoryView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kPhotosArePrivate]];
            break;
            
        case 4:
            // Facebook
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierShareFacebook];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierShareFacebook];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=NSLocalizedString(@"Facebook",@"Upload - Facebook");
            self.shareFacebook = [[UISwitch alloc] initWithFrame:CGRectZero];
            if([self.shareFacebook respondsToSelector:@selector(setOnTintColor:)]){
                //iOS 5.0
                [self.shareFacebook setOnTintColor:UIColorFromRGB(0xEFC005)];
            }
            [self.shareFacebook addTarget:self action:@selector(switchedFacebook) forControlEvents:UIControlEventValueChanged];
            [self.shareFacebook setOn:NO];
            cell.accessoryView = self.shareFacebook;
            break;
            
        case 5:
            // Twitter
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierShareTwitter];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierShareTwitter] ;
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=NSLocalizedString(@"Twitter",@"Upload - Twitter");
            self.shareTwitter = [[UISwitch alloc] initWithFrame:CGRectZero];
            if([self.shareTwitter respondsToSelector:@selector(setOnTintColor:)]){
                //iOS 5.0
                [self.shareTwitter setOnTintColor:UIColorFromRGB(0xEFC005)];
            }
            [self.shareTwitter addTarget:self action:@selector(switchedTwitter) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = self.shareTwitter;
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (UIButton *) makeDetailDisclosureButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // set the image
    UIImage *image = [UIImage imageNamed:@"button-disclosure-form.png"];
    [button setImage:image forState:UIControlStateNormal];
    
    CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.frame = frame;
    
    // action
    [button addTarget: self
               action: @selector(accessoryButtonTapped:withEvent:)
     forControlEvents: UIControlEventTouchUpInside];
    
    return button;
}

- (void) accessoryButtonTapped: (UIControl *) button withEvent: (UIEvent *) event{
    NSIndexPath * indexPath = [self.detailsPictureTable indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.detailsPictureTable]];
    if ( indexPath == nil )
        return;
    
    [self.detailsPictureTable.delegate tableView: self.detailsPictureTable accessoryButtonTappedForRowWithIndexPath: indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    if (row == 1){
        // tags
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:0];
        [self.navigationController pushViewController:self.tagController animated:YES];
    }else if (row == 2){
        // albums
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:0];
        [self.navigationController pushViewController:self.albumController animated:YES];
    }
}

-(void) switchedFacebook{
    if ([self.shareFacebook isOn]){
        [self.shareTwitter setOn:NO animated:YES];
    }
}

-(void) switchedTwitter{
    if ([self.shareTwitter isOn]){
        [self.shareFacebook setOn:NO animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)upload:(id)sender {
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"UI Action"
                                                      withAction:@"buttonPress"
                                                       withLabel:@"Upload"
                                                       withValue:nil];
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Upload button clicked. Save all details in the database");
#endif
    
    // values
    NSNumber *facebook = ([self.shareFacebook isOn] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO]) ;
    NSNumber *twitter = ([self.shareTwitter isOn] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO]);
    NSNumber *permission = (![self.permissionPicture isOn] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO]);
    NSString *title = self.titleTextField.text.length > 0 ? self.titleTextField.text : @"";
    NSString *tags = [self.tagController getSelectedTagsInJsonFormat];
    NSString *albums = [self.albumController getSelectedAlbumsIdentification];
    
    dispatch_queue_t waiting = dispatch_queue_create("waiting_finish_insert_database", NULL);
    dispatch_async(waiting, ^{
        @try {
            //
            //
            // Process all images in a queue.
            // When necessary to run in the main thread, do it
            // during this time, user will have a progress bar, so, no possible to change values
            //
            //
            
            // check the type of image that we are uploading
            // is it a single image or a bunch of images?
            if (self.images && [self.images count]>1){
                // bunch of photos and more than one
                int i = [self.images count];
                for ( NSURL *url in self.images){
                    if ( i != 1 ){
                        [self loadDataAndSaveEntityUploadDate:[NSDate date]
                                                shareFacebook:[NSNumber numberWithBool:NO]
                                                 shareTwitter:[NSNumber numberWithBool:NO]
                                                   permission:permission
                                                         tags:tags
                                                       albums:albums
                                                        title:title
                                                          url:url
                                                     groupUrl:nil];
                        
                        
                    }else{
                        // this is the last one,
                        // so we do the sharing if needed
                        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                        
                        // create the url to connect to OpenPhoto
                        NSString *urlString =     [NSString stringWithFormat: @"%@/photos/list?sortBy=dateUploaded,DESC&pageSize=%i", [standardUserDefaults valueForKey:kTroveboxServer], [self.images count]];
                        
                        [self loadDataAndSaveEntityUploadDate:[NSDate date]
                                                shareFacebook:facebook
                                                 shareTwitter:twitter
                                                   permission:permission
                                                         tags:tags
                                                       albums:albums
                                                        title:title
                                                          url:url
                                                     groupUrl:urlString];
                    }
                    
                    // decrease until the first one
                    i--;
                }
            }else{
                // just one photo to share
                [self loadDataAndSaveEntityUploadDate:[NSDate date]
                                        shareFacebook:facebook
                                         shareTwitter:twitter
                                           permission:permission
                                                 tags:tags
                                               albums:albums
                                                title:title
                                                  url:self.image
                                             groupUrl:nil];
            }
            
            // checkpoint
            if (self.images){
                [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Upload"
                                                                  withAction:@"typeImage"
                                                                   withLabel:@"Image from Sync"
                                                                   withValue:nil];
            }else{
                [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Upload"
                                                                  withAction:@"typeImage"
                                                                   withLabel:@"Image from Snapshot"
                                                                   withValue:nil];
            }
            
            // wait for 2 seconds to go to main screen
            [NSThread sleepForTimeInterval:2];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // stop loading
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                
                // if it comes form the sync,
                // go back in the navigation
                if (self.images){
                    [self.navigationController popViewControllerAnimated:NO];
                    [(MenuViewController*) SharedAppDelegate.menuController displayHomeScreen];
                }else{
                    [self dismissModalViewControllerAnimated:YES];
                }
            });
            
        }@catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:exception.description duration:5000];
                [alert showAlert];
                
                // go to home
                if (self.images){
                    [self.navigationController popViewControllerAnimated:NO];
                    [(MenuViewController*) SharedAppDelegate.menuController displayHomeScreen];
                }else{
                    [self dismissModalViewControllerAnimated:YES];
                }
            });
        }
    });
    dispatch_release(waiting);
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Preparing";
    
    // next visit to Newest Home does not need update
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDisableUpdateHome object:nil];
}

- (void) loadDataAndSaveEntityUploadDate:(NSDate *) date
                           shareFacebook:(NSNumber *) facebook
                            shareTwitter:(NSNumber *) twitter
                              permission:(NSNumber *) permission
                                    tags:(NSString *) tags
                                  albums:(NSString *) albums
                                   title:(NSString *) title
                                     url:(NSURL *) url
                                groupUrl:(NSString *) urlGroup
{
    // load image and then save it to database
    // via block
    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *asset)
    {
        
        ALAssetRepresentation *rep = [asset defaultRepresentation];
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"GOT ASSET, File size: %f", [rep size] / (1024.0f*1024.0f));
#endif
        uint8_t* buffer = malloc([rep size]);
        
        NSError* error = NULL;
        NSUInteger bytes = [rep getBytes:buffer fromOffset:0 length:[rep size] error:&error];
        NSData *data = nil;
        
        if (bytes == [rep size]){
#ifdef DEVELOPMENT_ENABLED
            NSLog(@"Asset %@ loaded from Asset Library OK", url);
#endif
            data = [NSData dataWithBytes:buffer length:bytes];
            [self saveEntityUploadDate:date
                         shareFacebook:facebook
                          shareTwitter:twitter
                                 image:data
                            permission:permission
                                  tags:tags
                                albums:albums
                                 title:title
                                   url:url
                              groupUrl:urlGroup];
        }else{
            NSLog(@"Error '%@' reading bytes from asset: '%@'", [error localizedDescription], url);
        }
        
        free(buffer);
    };
    
    // block for failed image
    ALAssetsLibraryAccessFailureBlock failureBlock  = ^(NSError *error)
    {
        NSLog(@"Error '%@' getting asset from library", [error localizedDescription]);
    };
    
    // schedules the asset read
    [self.assetsLibrary assetForURL:url resultBlock:resultBlock failureBlock:failureBlock];
}

- (void) saveEntityUploadDate:(NSDate *) date
                shareFacebook:(NSNumber *) facebook
                 shareTwitter:(NSNumber *) twitter
                        image:(NSData *) image
                   permission:(NSNumber *) permission
                         tags:(NSString *) tags
                       albums:(NSString *) albums
                        title:(NSString *) title
                          url:(NSURL *) url
                     groupUrl:(NSString *) urlGroup
{
    if ( image != nil){
        
        // generate a file name
        NSString *name = [AssetsLibraryUtilities getFileNameForImage:image url:url];
        
        // generate path of temporary file
        NSURL *pathTemporaryFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:name]];
        
        // save in a temporary folder
        BOOL result = [image writeToURL:pathTemporaryFile atomically:NO];
        
        // generate a thumb
        CGSize itemSize = CGSizeMake(70, 70);
        UIGraphicsBeginImageContext(itemSize);
        
        UIImage *imageTemp =  [UIImage imageWithData:image];
        [imageTemp drawInRect:CGRectMake(0, 0, 70, 70)];
        imageTemp = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData* data =[NSData dataWithData:UIImagePNGRepresentation (imageTemp)];
        
        
        //in the main queue, generate TimelinePhotos
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool{
                if (result){
                    // data to be saved in the database
                    Timeline *uploadInfo =  [NSEntityDescription insertNewObjectForEntityForName:@"Timeline"
                                                                          inManagedObjectContext:[SharedAppDelegate managedObjectContext]];
                    
                    // details form this upload
                    uploadInfo.date = date;
                    uploadInfo.dateUploaded = date;
                    uploadInfo.facebook = facebook;
                    uploadInfo.twitter = twitter;
                    uploadInfo.permission = permission;
                    uploadInfo.title =  title;
                    uploadInfo.tags=tags;
                    uploadInfo.albums=albums;
                    uploadInfo.status=kUploadStatusTypeCreated;
                    uploadInfo.photoDataTempUrl = [pathTemporaryFile absoluteString];
                    uploadInfo.photoDataThumb = data;
                    uploadInfo.fileName = name;
                    uploadInfo.userUrl = [SharedAppDelegate userHost];
                    uploadInfo.photoToUpload = [NSNumber numberWithBool:YES];
                    uploadInfo.photoUploadMultiplesUrl = urlGroup;
                    
                    if (url){
                        // add to the sync list, with that we don't need to show photos already uploaded.
                        uploadInfo.syncedUrl = [AssetsLibraryUtilities getAssetsUrlId:url];
                    }
                }}
        });
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error.localizedDescription != nil){
        NSLog(@"Image could not be saved = %@", error.localizedDescription);
    }else{
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Image saved");
#endif
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1){
        [(MenuViewController*) SharedAppDelegate.menuController displayProfileScreen];
    }
}


@end

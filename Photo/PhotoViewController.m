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
                        title:(NSString *) title
                          url:(NSURL *) url
                     groupUrl:(NSString *) urlGroup;

- (void) loadDataAndSaveEntityUploadDate:(NSDate *) date
                           shareFacebook:(NSNumber *) facebook
                            shareTwitter:(NSNumber *) twitter
                              permission:(NSNumber *) permission
                                    tags:(NSString *) tags
                                   title:(NSString *) title
                                     url:(NSURL *) url
                                groupUrl:(NSString *) urlGroup;

// this method is used in case of in Multiples Uploads the user choose only one picure. we should enable him to edit the image
- (void) loadImageToEdit:(NSURL *) url;
- (void)upload:(id)sender;

@end

@implementation PhotoViewController

@synthesize detailsPictureTable=_detailsPictureTable;
@synthesize originalImage=_originalImage, imageFiltered=_imageFiltered;
@synthesize titleTextField=_titleTextField, permissionPicture=_permissionPicture, shareFacebook=_shareFacebook, shareTwitter=_shareTwitter;
@synthesize tagController=_tagController;

@synthesize image= _image;
@synthesize images = _images;

// assets
@synthesize assetsLibrary = _assetsLibrary;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL *) imageFromCamera image:(UIImage*) originalImage
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        self.image = imageFromCamera;
        self.originalImage = originalImage;
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        // initialization of tag controller
        self.tagController = [[TagViewController alloc] init];
        [self.tagController setReadOnly];
        
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
                [self loadImageToEdit:self.image];
            }
        }
        
        // initialization of tag controller
        self.tagController = [[TagViewController alloc] init];
        [self.tagController setReadOnly];
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
    }else{
        // if user wants to cancel the upload
        // it should be just in the case of snapshot
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelUploadButton)];
        self.navigationItem.leftBarButtonItem = cancelButton;
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


- (void)viewDidUnload{
    [super viewDidUnload];
    [self setDetailsPictureTable:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.image == nil){
        // user comes from the Sync, we don't show Aviary
        return 5;
    }else{
        // show all possibilites
        return 6;
    }
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
                
                self.titleTextField.placeholder = @"title";
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
            
            cell.textLabel.text=@"Tags";
            // customised disclosure button
            [cell setAccessoryView:[self makeDetailDisclosureButton]];
            break;
            
        case 2:
            // private flag
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierPrivate];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierPrivate];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"Private";
            self.permissionPicture = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = self.permissionPicture;
            
            if([self.permissionPicture respondsToSelector:@selector(setOnTintColor:)]){
                //iOS 5.0
                [self.permissionPicture setOnTintColor:UIColorFromRGB(0xEFC005)];
            }
            
            // get from user configuration if pictures should be private or not
            [(UISwitch *)cell.accessoryView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kPhotosArePrivate]];
            break;
            
        case 3:
            // Facebook
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierShareFacebook];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierShareFacebook];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"Facebook";
            self.shareFacebook = [[UISwitch alloc] initWithFrame:CGRectZero];
            if([self.shareFacebook respondsToSelector:@selector(setOnTintColor:)]){
                //iOS 5.0
                [self.shareFacebook setOnTintColor:UIColorFromRGB(0xEFC005)];
            }
            [self.shareFacebook addTarget:self action:@selector(switchedFacebook) forControlEvents:UIControlEventValueChanged];
            [self.shareFacebook setOn:NO];
            cell.accessoryView = self.shareFacebook;
            break;
            
        case 4:
            // Twitter
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierShareTwitter];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierShareTwitter] ;
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"Twitter";
            self.shareTwitter = [[UISwitch alloc] initWithFrame:CGRectZero];
            if([self.shareTwitter respondsToSelector:@selector(setOnTintColor:)]){
                //iOS 5.0
                [self.shareTwitter setOnTintColor:UIColorFromRGB(0xEFC005)];
            }
            [self.shareTwitter addTarget:self action:@selector(switchedTwitter) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = self.shareTwitter;
            break;
            
        case 5:
            // filter Aviary
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierFilter];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierFilter];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"Crop & effects";
            // customised disclosure button
            [cell setAccessoryView:[self makeDetailDisclosureButton]];
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
    }else if ( row == 5){
        // filter
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:0];
        AFPhotoEditorController *editorController = [[AFPhotoEditorController alloc] initWithImage:self.originalImage];
        [editorController setDelegate:self];
        [self presentViewController:editorController animated:YES completion:nil];
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

- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Image changed");
#endif
    [editor dismissViewControllerAnimated:YES completion:^{
          self.imageFiltered = image;
    }];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Widget canceled");
#endif
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
    UIImage  *imageFiltered = self.imageFiltered;
    
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
            // is it a single image, a bunch of images or the user used Aviary?
            if (imageFiltered){
                //image filtered. User used Aviary
                [self saveEntityUploadDate:[NSDate date]
                             shareFacebook:facebook
                              shareTwitter:twitter
                                     image:UIImageJPEGRepresentation(imageFiltered,0.7)
                                permission:permission
                                      tags:tags
                                     title:title
                                       url:nil
                                  groupUrl:nil];
            }else if (self.images && [self.images count]>1){
                // bunch of photos and more than one
                int i = [self.images count];
                for ( NSURL *url in self.images){
                    if ( i != 1 ){
                        [self loadDataAndSaveEntityUploadDate:[NSDate date]
                                                shareFacebook:[NSNumber numberWithBool:NO]
                                                 shareTwitter:[NSNumber numberWithBool:NO]
                                                   permission:permission
                                                         tags:tags
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
                                                title:title
                                                  url:self.image
                                             groupUrl:nil];
            }
            
            // checkpoint
            if (self.imageFiltered){
                [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Upload"
                                                                  withAction:@"typeImage"
                                                                   withLabel:@"Image from Aviary"
                                                                   withValue:nil];
            }else if (self.images){
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
                }else{
                    [self dismissModalViewControllerAnimated:YES];
                }
                
                 [self.viewDeckController  closeRightViewAnimated:YES];
            });
            
        }@catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:exception.description duration:5000];
                [alert showAlert];
                
                // go to home
                if (self.images){
                    [self.navigationController popViewControllerAnimated:NO];
                }else{
                    [self dismissModalViewControllerAnimated:YES];
                }
                
                 [self.viewDeckController  closeRightViewAnimated:YES];
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

- (void) loadImageToEdit:(NSURL *) url
{
    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *asset)
    {
        self.originalImage =[UIImage imageWithCGImage:[asset defaultRepresentation].fullScreenImage scale:1.0 orientation:(UIImageOrientation)[asset defaultRepresentation].orientation];
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock  = ^(NSError *error)
    {
        NSLog(@"Unresolved error: %@, %@", error, [error localizedDescription]);
    };
    
    [self.assetsLibrary assetForURL:url
                        resultBlock:resultBlock
                       failureBlock:failureBlock];
}

- (void) saveEntityUploadDate:(NSDate *) date
                shareFacebook:(NSNumber *) facebook
                 shareTwitter:(NSNumber *) twitter
                        image:(NSData *) image
                   permission:(NSNumber *) permission
                         tags:(NSString *) tags
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

@end

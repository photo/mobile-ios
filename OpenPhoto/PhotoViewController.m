//
//  PhotoViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 29/07/11.
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

@end

@implementation PhotoViewController
@synthesize uploadButton = _uploadButton;

@synthesize detailsPictureTable=_detailsPictureTable;
@synthesize originalImage=_originalImage, imageFiltered=_imageFiltered;
@synthesize titleTextField=_titleTextField, permissionPicture=_permissionPicture, shareFacebook=_shareFacebook, shareTwitter=_shareTwitter;
@synthesize tagController=_tagController;

@synthesize image= _image;
@synthesize images = _images;

@synthesize imagesToProcess = _imagesToProcess;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL *) imageFromCamera image:(UIImage*) originalImage;{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        self.image = imageFromCamera;
        self.originalImage = originalImage;
        self.imagesToProcess = 1;
        
        // initialization of tag controller
        self.tagController = [[TagViewController alloc] init];
        [self.tagController setReadOnly];
        assetsLibrary = [[ALAssetsLibrary alloc] init]; 
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil images:(NSArray *) imagesFromSync{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        self.images = imagesFromSync;
        
        // how many images we need to process?
        if (self.images){
            self.imagesToProcess = [self.images count];
            
            // if there is only one, treat it as a camera image, so user will be able to edit
            if ([self.images count] == 1){
                self.image = [self.images lastObject];
                [self loadImageToEdit:self.image];
            }
        }
        
        // initialization of tag controller
        self.tagController = [[TagViewController alloc] init];
        [self.tagController setReadOnly];
        assetsLibrary = [[ALAssetsLibrary alloc] init]; 
    }
    return self;
}


#pragma mark - View lifecycle
- (void)viewDidLoad{  
    [super viewDidLoad];
    
    self.title = @"Upload";
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (self.images){
        self.detailsPictureTable.frame = CGRectMake(self.detailsPictureTable.frame.origin.x,self.detailsPictureTable.frame.origin.y - 10, self.detailsPictureTable.frame.size.width,self.detailsPictureTable.frame.size.height);
        self.uploadButton.frame = CGRectMake(self.uploadButton.frame.origin.x,self.uploadButton.frame.origin.y - 80, self.uploadButton.frame.size.width,self.uploadButton.frame.size.height);       
    }else{
                self.detailsPictureTable.frame = CGRectMake(self.detailsPictureTable.frame.origin.x,self.detailsPictureTable.frame.origin.y + 30, self.detailsPictureTable.frame.size.width,self.detailsPictureTable.frame.size.height);
        self.uploadButton.frame = CGRectMake(self.uploadButton.frame.origin.x,self.uploadButton.frame.origin.y - 10, self.uploadButton.frame.size.width,self.uploadButton.frame.size.height);
        // if user wants to cancel the upload
        // it should be just in the case of snapshot
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelUploadButton)];          
        self.navigationItem.rightBarButtonItem = cancelButton;
        [cancelButton release];
    }    
}


- (void) cancelUploadButton{
    [self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidUnload{
    [self setUploadButton:nil];
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
    UITableViewCell *cell;
    
    NSUInteger row = [indexPath row];
    switch (row) {
        case 0:
            // title
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierTitle];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierTitle] autorelease];
                self.titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(17 , 13, 260, 21)];
                self.titleTextField.adjustsFontSizeToFitWidth = YES;
                self.titleTextField.textColor = UIColorFromRGB(0xE6501E);
                
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
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierTags] autorelease];
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
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierPrivate] autorelease];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"Private";
            self.permissionPicture = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
            cell.accessoryView = self.permissionPicture;
            
            if([self.permissionPicture respondsToSelector:@selector(setOnTintColor:)]){
                //iOS 5.0
                [self.permissionPicture setOnTintColor:[UIColor redColor]];
            }
            
            // get from user configuration if pictures should be private or not
            [(UISwitch *)cell.accessoryView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kPhotosArePrivate]];
            break;
            
        case 3:
            // Facebook
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierShareFacebook];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierShareFacebook] autorelease];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"Facebook";
            self.shareFacebook = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
            if([self.shareFacebook respondsToSelector:@selector(setOnTintColor:)]){
                //iOS 5.0
                [self.shareFacebook setOnTintColor:[UIColor redColor]];
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
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierShareTwitter] autorelease];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"Twitter";
            self.shareTwitter = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
            if([self.shareTwitter respondsToSelector:@selector(setOnTintColor:)]){
                //iOS 5.0
                [self.shareTwitter setOnTintColor:[UIColor redColor]];
            }
            [self.shareTwitter addTarget:self action:@selector(switchedTwitter) forControlEvents:UIControlEventValueChanged];  
            cell.accessoryView = self.shareTwitter;
            break;
            
        case 5:
            // filter Aviary
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierFilter];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierFilter] autorelease];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"Crop & effects";
            // customised disclosure button
            [cell setAccessoryView:[self makeDetailDisclosureButton]];            
            break;
            
        default:
            break;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
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
        AFFeatherController *controller = [[AFFeatherController alloc] 
                                           initWithImage:self.originalImage];
        controller.delegate = self;
        
        [self presentModalViewController:controller animated:YES];
        [controller release];
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

- (void)feather:(AFFeatherController *)featherController finishedWithImage:(UIImage *)image{
    NSLog(@"Image changed");
    self.imageFiltered = image;
}

- (void)featherCanceled:(AFFeatherController *)featherController{
    NSLog(@"Widget canceled");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)upload:(id)sender {     
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
                        NSString *urlString =     [NSString stringWithFormat: @"%@/photos/list?sortBy=dateUploaded,DESC&pageSize=%i", [standardUserDefaults valueForKey:kOpenPhotoServer], [self.images count]];
                        
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
            
            
            // create a thread that check if all data is processed,
            // when all the the assetslibrary job is done save database 
            // and goes to main screen
            // this will sleep for 0.5 seconds
            while (TRUE) {
                // sleep for 0.5 seconds
                [NSThread sleepForTimeInterval:0.5];
#ifdef DEVELOPMENT_ENABLED
                NSLog(@"Checking if everything is saved");
#endif
                // check if counter is 0
                if (self.imagesToProcess < 1){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // save all objects in the context
                        NSError *uploadError = nil;
                        if (![[AppDelegate managedObjectContext] save:&uploadError]){
                            NSLog(@"Error saving uploading = %@",[uploadError localizedDescription]);
                        }else{
#ifdef DEVELOPMENT_ENABLED
                            NSLog(@"Data ready to send to openphoto. Everything saved on database");
#endif
                        }
                        
#ifdef TEST_FLIGHT_ENABLED
                        // checkpoint
                        if (self.imageFiltered){
                            [TestFlight passCheckpoint:@"Image from Aviary"];       
                        }else if (self.images){
                            [TestFlight passCheckpoint:@"Image from Sync"];
                        }else{
                            [TestFlight passCheckpoint:@"Image from Snapshot"];
                        }
#endif 
                        
                        // stop loading
                        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                        
                        // if it comes form the sync,
                        // go back in the navigation
                        if (self.images){
                            [self.navigationController popViewControllerAnimated:NO];
                        }
                        
                        // go to home
                        [AppDelegate openTab:0];
                        [self dismissModalViewControllerAnimated:YES];
                    });
                    break;
                }
            }            
        }@catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];                    
                OpenPhotoAlertView *alert = [[OpenPhotoAlertView alloc] initWithMessage:exception.description duration:5000];
                [alert showAlert];
                [alert release];                
                // go to home
                [AppDelegate openTab:0];
                [self dismissModalViewControllerAnimated:YES];
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
            data = [[NSData dataWithBytes:buffer length:bytes] retain];
        }else{
            NSLog(@"Error '%@' reading bytes from asset: '%@'", [error localizedDescription], url);
        }
        
        free(buffer);
        
        [self saveEntityUploadDate:date
                     shareFacebook:facebook 
                      shareTwitter:twitter 
                             image:data
                        permission:permission
                              tags:tags
                             title:title
                               url:url
                          groupUrl:urlGroup];
    };
    
    // block for failed image
    ALAssetsLibraryAccessFailureBlock failureBlock  = ^(NSError *error)
    {
        NSLog(@"Error '%@' getting asset from library", [error localizedDescription]);
    };
    
    // schedules the asset read       
    [assetsLibrary assetForURL:url resultBlock:resultBlock failureBlock:failureBlock];
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
    
    [assetsLibrary assetForURL:url
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if (image != nil){
            // data to be saved in the database
            TimelinePhotos *uploadInfo =  [NSEntityDescription insertNewObjectForEntityForName:@"TimelinePhotos" 
                                                                        inManagedObjectContext:[AppDelegate managedObjectContext]];
            
            // details form this upload
            uploadInfo.date = date;
            uploadInfo.dateUploaded = date;
            uploadInfo.facebook = facebook;
            uploadInfo.twitter = twitter;
            uploadInfo.permission = permission;
            uploadInfo.title =  title;
            uploadInfo.tags=tags;
            uploadInfo.status=kUploadStatusTypeCreated;
            uploadInfo.photoData = image;
            uploadInfo.fileName = [AssetsLibraryUtilities getFileNameForImage:image url:url];
            uploadInfo.status=kUploadStatusTypeCreated;
            uploadInfo.userUrl = [AppDelegate user];
            uploadInfo.photoToUpload = [NSNumber numberWithBool:YES];
            uploadInfo.photoUploadMultiplesUrl = urlGroup;
            
            if (url){
                // add to the sync list, with that we don't need to show photos already uploaded.
                uploadInfo.syncedUrl = [AssetsLibraryUtilities getAssetsUrlId:url];
            }
            
            // decrease counter
            self.imagesToProcess = self.imagesToProcess - 1;
        }});
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    [image release];
    if (error.localizedDescription != nil){
        NSLog(@"Image could not be saved = %@", error.localizedDescription);
    }else{
        NSLog(@"Image saved");
    }
}

- (void)dealloc {
    [self.originalImage release];
    [self.imageFiltered release];
    [self.detailsPictureTable release];
    [self.titleTextField release];
    [self.permissionPicture release];
    [self.shareTwitter release];
    [self.shareFacebook release];
    [self.tagController release];
    [self.image release];
    [self.images release];
    [assetsLibrary release];
    
    [_uploadButton release];
    [super dealloc];
}

@end

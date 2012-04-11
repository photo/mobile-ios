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
-(void) switchedFacebook;
-(void) switchedTwitter;

- (NSString *) getFileNameFilterImage:(BOOL) filtered data:(NSData*)data url:(NSURL*) url;

@end

@implementation PhotoViewController

@synthesize detailsPictureTable=_detailsPictureTable;
@synthesize urlImageOriginal=_urlImageOriginal, imageOriginal=_imageOriginal, imageFiltered=_imageFiltered;
@synthesize titleTextField=_titleTextField, permissionPicture=_permissionPicture, shareFacebook=_shareFacebook, shareTwitter=_shareTwitter;
@synthesize tagController=_tagController, sourceType=_sourceType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil photoUrl:(NSURL *) url photo:(UIImage *) image source:(UIImagePickerControllerSourceType) pickerSourceType{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.urlImageOriginal = url;
        self.imageOriginal = image;
        self.sourceType = pickerSourceType;
        
        // initialization of tag controller
        self.tagController = [[TagViewController alloc] init];
        [self.tagController setReadOnly];
    }
    return self;
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle
- (void)viewDidLoad{  
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // if user wants to cancel the upload
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelUploadButton)];          
    self.navigationItem.rightBarButtonItem = cancelButton;
    [cancelButton release];
    
    [super viewDidLoad];
}

- (void) cancelUploadButton{
    [self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidUnload{
    [super viewDidUnload];
    [imageTitle release];
    imageTitle = nil;
    [self setDetailsPictureTable:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return kNumbersRow;
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
    
    if ( row == 5){
        // filter
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:0];
        AFFeatherController *controller = [[AFFeatherController alloc] 
                                           initWithImage:self.imageOriginal];
        controller.delegate = self;
        
        [self presentModalViewController:controller animated:YES];
        [controller release];
    }else if (row == 1){
        // tags
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:0];
        [self.navigationController pushViewController:self.tagController animated:YES];
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
    
    UploadPhotos *uploadInfo =  [NSEntityDescription insertNewObjectForEntityForName:@"UploadPhotos" 
                                                              inManagedObjectContext:[AppDelegate managedObjectContext]];
    //
    // add all details in the database
    //
    
    // date
    uploadInfo.date = [NSDate date];
    
    // facebook
    uploadInfo.facebook = ([self.shareFacebook isOn] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO]);
    
    // twitter
    uploadInfo.twitter = ([self.shareTwitter isOn] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO]);
    
    // permissionPrivate
    uploadInfo.permission = (![self.permissionPicture isOn] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO]);
    
    // source
    if (self.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
        uploadInfo.source=kUploadSourceUIImagePickerControllerSourceTypePhotoLibrary;
    }else if (self.sourceType == UIImagePickerControllerSourceTypeCamera){
        uploadInfo.source=kUploadSourceUIImagePickerControllerSourceTypeCamera;
    }else if (self.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum){
        uploadInfo.source=kUploadSourceUIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    
    // tags
    uploadInfo.tags=[self.tagController getSelectedTagsInJsonFormat];
    
    // title
    uploadInfo.title = self.titleTextField.text.length > 0 ? self.titleTextField.text : @"";
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Title photo %@",uploadInfo.title);
#endif    
    
    // fileName and data    
    if (self.imageFiltered != nil){
        uploadInfo.image = UIImageJPEGRepresentation(self.imageFiltered,0.7);
        uploadInfo.fileName = [self getFileNameFilterImage:YES data:uploadInfo.image url:nil];
        uploadInfo.status=kUploadStatusTypeCreated;
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Data ready to send to openphoto. Saved on database");
#endif
        
#ifdef TEST_FLIGHT_ENABLED
        [TestFlight passCheckpoint:@"Edited imaged saved on database to upload"];
#endif
        // go to home
        [AppDelegate openTab:0];
        [self dismissModalViewControllerAnimated:YES];
    }else {
        // Get image from Assets Library
        // the result block
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            ALAssetRepresentation *rep = [myasset defaultRepresentation];
#ifdef DEVELOPMENT_ENABLED            
            NSLog(@"GOT ASSET, File size: %f", [rep size] / (1024.0f*1024.0f)); 
#endif           
            uint8_t* buffer = malloc([rep size]);
            
            NSError* error = NULL;
            NSUInteger bytes = [rep getBytes:buffer fromOffset:0 length:[rep size] error:&error];
            NSData *data = nil;
            
            if (bytes == [rep size])
            {
#ifdef DEVELOPMENT_ENABLED
                NSLog(@"Asset %@ loaded from Asset Library OK", self.urlImageOriginal);
#endif
                data = [[NSData dataWithBytes:buffer length:bytes] retain];
            }
            else
            {
                NSLog(@"Error '%@' reading bytes from asset: '%@'", [error localizedDescription], self.urlImageOriginal);
            }
            
            free(buffer);
            
            // show alert to user
            dispatch_async(dispatch_get_main_queue(), ^{
                uploadInfo.image = data;
                uploadInfo.fileName = [self getFileNameFilterImage:NO data:data url:self.urlImageOriginal];
                
                // status
                uploadInfo.status=kUploadStatusTypeCreated;
                
                // save
                NSError *uploadError = nil;
                if (![[AppDelegate managedObjectContext] save:&uploadError]){
                    NSLog(@"Error saving uploading = %@",[uploadError localizedDescription]);
                }   
                
#ifdef DEVELOPMENT_ENABLED
                NSLog(@"Data ready to send to openphoto. Saved on database");
#endif
                
#ifdef TEST_FLIGHT_ENABLED
                [TestFlight passCheckpoint:@"Image saved on database to upload"];
#endif
                // go to home
                [AppDelegate openTab:0];
                [self dismissModalViewControllerAnimated:YES];
            });
            
        };
        
        //
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
        {
            NSLog(@"Error '%@' getting asset from library", [myerror localizedDescription]);
        };
        
        // schedules the asset read
        ALAssetsLibrary* assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];
        
        [assetslibrary assetForURL:self.urlImageOriginal
                       resultBlock:resultblock
                      failureBlock:failureblock];
    }    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    [image release];
    if (error.localizedDescription != nil){
        NSLog(@"Image could not be saved = %@", error.localizedDescription);
    }else{
        NSLog(@"Image saved");
    }
}

- (NSString *) getFileNameFilterImage:(BOOL) filtered data:(NSData*)data url:(NSURL*) url
{
    if (filtered){
        // filtered
        CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
        
        // get type of the file
        NSString *extension = [ContentTypeUtilities contentTypeExtensionForImageData:data];
        
        return [NSString stringWithFormat:@"%@.%@",(NSString *) newUniqueIdString,extension];
    }else{
        // no filter, image is located on Library
        return [NSString stringWithFormat:@"%@.%@",[AssetsLibraryUtilities getAssetsUrlId:url],[AssetsLibraryUtilities getAssetsUrlExtension:url]];
    }
}

- (void)dealloc {
    [imageTitle release];
    [self.urlImageOriginal release];
    [self.imageOriginal release];
    [self.imageFiltered release];
    [self.detailsPictureTable release];
    [self.titleTextField release];
    [self.permissionPicture release];
    [self.shareTwitter release];
    [self.shareFacebook release];
    [self.tagController release];
    
    [super dealloc];
}

@end

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
-(void) uploadPicture:(NSData*) data metadata:(NSDictionary*) values filename:(NSString*) fileName fileToDelete:(NSString*) fileToDelete;
-(void) switchedFacebook;
-(void) switchedTwitter;
@end

@implementation PhotoViewController

@synthesize detailsPictureTable;
@synthesize urlImageOriginal, imageOriginal, imageFiltered;
@synthesize titleTextField, permissionPicture, shareFacebook, shareTwitter;
@synthesize tagController, sourceType;
@synthesize service;
@synthesize fileNameToDelete;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil photoUrl:(NSURL *) url photo:(UIImage *) image source:(UIImagePickerControllerSourceType) pickerSourceType{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.urlImageOriginal = url;
        self.imageOriginal = image;
        self.sourceType = pickerSourceType;
        
        // initialization of tag controller
        self.tagController = [[[TagViewController alloc] init]autorelease];
        [self.tagController setReadOnly];
        
        // to send the request via the web service class
        self.service = [[WebService alloc]init];
        [self.service setDelegate:self];
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


- (void) notifyUserNoInternet{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // problem with internet, show message to user
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet error" message:@"Couldn't reach the server. Please, check your internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
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
                self.titleTextField.textColor = [UIColor redColor];
                
                self.titleTextField.placeholder = @"title";
                self.titleTextField.keyboardType = UIKeyboardTypeDefault;
                self.titleTextField.returnKeyType = UIReturnKeyDone;
                self.titleTextField.delegate = self;
                [cell addSubview:titleTextField];
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
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
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
            
            if([self.permissionPicture respondsToSelector:@selector(setOnTintColor)]){
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
            if([self.shareFacebook respondsToSelector:@selector(setOnTintColor)]){
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
            if([self.shareTwitter respondsToSelector:@selector(setOnTintColor)]){
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
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            break;
            
        default:
            break;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
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
    NSLog(@"Upload button clicked. Create all information for the request");
#endif
    
    
    // show the progress bar and create a block    
    HUD = [[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES] retain];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText=@"Preparing";
    HUD.delegate = self;
    
    // title
    NSString *title = (self.titleTextField.text.length > 0 ? self.titleTextField.text : @"");
    
    // default permission for the pictures is PUBLIC
    NSString *permission = @"1";
    
    if ([permissionPicture isOn]){
        permission = @"0";
    }
    
    // TODO, if iOS 5 you can get this data + name
    //filename
    NSString *filename= [NSString stringWithFormat:@"%@.%@",[AssetsLibraryUtilities getAssetsUrlId:self.urlImageOriginal],[AssetsLibraryUtilities getAssetsUrlExtension:self.urlImageOriginal]];
    self.fileNameToDelete = filename;
    
    // parameters to upload
    NSArray *keys = [NSArray arrayWithObjects:@"image", @"hasFilter", @"title", @"permission",@"tags",@"filename",nil];
    NSArray *objects;
    
    // set the correct image to upload depends if there is a filtered or not.
    if (self.imageFiltered != nil){
        objects = [NSArray arrayWithObjects:self.imageFiltered, [NSNumber numberWithBool:YES], [QSStrings htmlEntities:title], permission, [tagController getSelectedTagsInJsonFormat],filename, nil];
    } else{
        objects = [NSArray arrayWithObjects:self.urlImageOriginal, [NSNumber numberWithBool:NO],[QSStrings htmlEntities:title], permission, [tagController getSelectedTagsInJsonFormat],filename, nil]; 
    }
    
    NSDictionary *values = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    // just save if it cames from the camera and the user filtered.
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera){
        // save filtered picture local
        if ( [[NSUserDefaults standardUserDefaults] boolForKey:kPhotosSaveCameraRollOrSnapshot] == YES && self.imageFiltered != nil){
            UIImageWriteToSavedPhotosAlbum([self.imageFiltered retain], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Start the procedure to send the request");
#endif
    if (service.internetActive == YES && service.hostActive == YES){
        
        // create a queue to use GCD and upload the image
        dispatch_queue_t downloadQueue = dispatch_queue_create("uploader_queue", NULL);
        dispatch_async(downloadQueue, ^{
            // data to send to OpenPhoto
            __block NSData *data = nil;
            
            // check if it a filtered image or a URL
            BOOL hasFilter = [[values objectForKey:@"hasFilter"] boolValue];
            
            if (hasFilter){
                // it has filter, so we have to create a NSSdata
                data = UIImageJPEGRepresentation([values objectForKey:@"image"] ,0.7);
                [self uploadPicture:data metadata:values filename:[values objectForKey:@"filename"] fileToDelete:nil];
            }else{
                // the photo is inside AssetLibrary
                NSLog(@"URL %@",[values objectForKey:@"image"]);
                
                NSURL *assetURL = [values objectForKey:@"image"];
                
                // name of local file
                NSDate *now = [NSDate date];
                double uniqueId = [now timeIntervalSince1970];
                
                NSString *formDataFileName = [[NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%if", uniqueId]] retain];
                
                NSLog(@"File used for transfer = %@, it will be deleted",formDataFileName  );
                
                // get the image data using the Assets Library
                ALAssetsLibraryAssetForURLResultBlock resultBlock = 
                ^(ALAsset *asset) {
                    ALAssetRepresentation *representation = [asset defaultRepresentation];
                    NSOutputStream *mediaStream = [NSOutputStream outputStreamToFileAtPath:formDataFileName append:YES];
                    [mediaStream open];
                    
                    NSUInteger bufferSize = 8192;
                    NSUInteger read = 0, offset = 0, written = 0;
                    uint8_t	   *buff = (uint8_t *)malloc(sizeof(uint8_t)*bufferSize);
                    NSError	   *err = nil;
                    
                    do {
                        read = [representation getBytes:buff fromOffset:offset length:bufferSize error:&err];
                        written = [mediaStream write:buff maxLength:read];
                        offset += read;
                        if (err != nil) {
                            NSLog(@"Error to save the file" );
                            [mediaStream close];
                            free(buff);
                            return;
                        }
                        if (read != written) {
                            [mediaStream close];
                            free(buff);
                            return;
                        }
                    } while (read != 0);
                    free(buff);
                    [mediaStream close];
                    
                    
                    // set the data in the local NSData            
                    data = [[NSData alloc] initWithContentsOfFile:formDataFileName];
                    [self uploadPicture:data metadata:values filename:[values objectForKey:@"filename"] fileToDelete:formDataFileName];
                };
                
                ALAssetsLibrary *assetLib = [[[ALAssetsLibrary alloc] init] autorelease];
                [assetLib assetForURL:assetURL resultBlock:resultBlock failureBlock:^(NSError *error) {
                    NSLog(@"Error from assertURL %@",[error localizedDescription]);
                }];
                
            }
        });
        dispatch_release(downloadQueue );
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet Connection" message:@"Please, check your connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        [HUD hide:YES];
        [self dismissModalViewControllerAnimated:YES];
    }
}

-(void) uploadPicture:(NSData*) data metadata:(NSDictionary*) values filename:(NSString*) fileName fileToDelete:(NSString*) fileToDelete{
    // TODO in the case of filtered imaged, we should set @"Apple",[[UIDevice currentDevice] model],
    
    // set all details to send
    NSString *uploadCall = [NSString stringWithFormat:@"title=%@&permission=%@&tags=%@",[values objectForKey:@"title"],[values objectForKey:@"permission"], [values objectForKey:@"tags"]];
    
    NSLog(@"Title %@",[values objectForKey:@"title"]);
    
    NSMutableString *urlString = [NSMutableString stringWithFormat: @"%@/photo/upload.json", [[NSUserDefaults standardUserDefaults] stringForKey:kOpenPhotoServer]];
    NSURL *url = [NSURL URLWithString:urlString];
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Url upload = [%@]. Execute OAuth and Multipart",urlString);
#endif
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    // token to send. We get the details from the user defaults
    OAToken *token = [[OAToken alloc] initWithKey:[standardUserDefaults valueForKey:kAuthenticationOAuthToken] 
                                           secret:[standardUserDefaults valueForKey:kAuthenticationOAuthSecret]];
    
    //consumer to send. We get the details from the user defaults
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:[standardUserDefaults valueForKey:kAuthenticationConsumerKey] 
                                                    secret:[standardUserDefaults valueForKey:kAuthenticationConsumerSecret] ];
    
    OAMutableURLRequest *oaUrlRequest = [[OAMutableURLRequest alloc] initWithURL:url
                                                                        consumer:consumer
                                                                           token:token
                                                                           realm:nil
                                                               signatureProvider:nil];
    [oaUrlRequest setHTTPMethod:@"POST"]; 
    [oaUrlRequest setValue:[NSString stringWithFormat:@"%d",[uploadCall length]] forHTTPHeaderField:@"Content-length"];
    [oaUrlRequest setHTTPBody:[uploadCall dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]];
    
    // prepare the request. This will be used to get the Authorization header and add in the multipart component        
    [oaUrlRequest prepare];
    
    
    /*
     *
     *   Using ASIHTTPRequest for Multipart. The authentication come from the OAMutableURLRequest
     *
     */
    __block  ASIFormDataRequest *asiRequest = [ASIFormDataRequest requestWithURL:url];
    
    // set the authorization header to be used in the OAuth            
    NSDictionary *dictionary =  [oaUrlRequest allHTTPHeaderFields];
    [asiRequest addRequestHeader:@"Authorization" value:[dictionary objectForKey:@"Authorization"]];
    
    // set the parameter already added in the signature
    [asiRequest addPostValue:[values objectForKey:@"title"] forKey:@"title"];
    [asiRequest addPostValue:[values objectForKey:@"permission"] forKey:@"permission"];
    [asiRequest addPostValue:[values objectForKey:@"tags"] forKey:@"tags"];
    
    // add the file in the multipart. This file is stored locally for perfomance reason. We don't have to load it
    // in memory. If it is a picture with filter, we just send without giving the name 
    // and content type
    [asiRequest addData:data withFileName:fileName andContentType:@"image/png" forKey:@"photo"];
    
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Token created, request ready to be sent");
#endif
    
    dispatch_async(dispatch_get_main_queue(), ^{
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.labelText = @"Sending";
        
    });
    
    [asiRequest setCompletionBlock:^{
        NSLog(@"Request done");
        // convert the responseDate to the json string
        NSString *jsonString = [asiRequest responseString];
        
#ifdef DEVELOPMENT_ENABLED  
        NSLog(@"jsonString = %@",jsonString);       
#endif 
        
        // Create a dictionary from JSON string
        // When there are newline characters in the JSON string, 
        // the error "Unescaped control character '0x9'" will be thrown. This removes those characters.
        jsonString =  [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSDictionary *response =  [jsonString JSONValue]; 
        
        // check if message is valid
        if (![WebService isMessageValid:response]){
            NSString* message = [WebService getResponseMessage:response];
            NSLog(@"Invalid response = %@",message);
            
            // show alert to user
            dispatch_async(dispatch_get_main_queue(), ^{
                
                HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = @"Error";
                [HUD hide:YES];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Response Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                [alert release];
                
                
            });
        }else{
            
#ifdef TEST_FLIGHT_ENABLED
            [TestFlight passCheckpoint:@"Picture uploaded"];
#endif
            
            
            // ATTENTION: remove the file form the local system. It was used only to create the multipart
            if (    self.fileNameToDelete  != nil){
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([fileManager fileExistsAtPath:    self.fileNameToDelete ]) {
                    BOOL __unused removeResult = NO;
                    NSError *error = nil;
                    removeResult = [fileManager removeItemAtPath:    self.fileNameToDelete  error:&error];
                }  
            }
            
            // progress bar
            dispatch_async(dispatch_get_main_queue(), ^{
                HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = @"Uploaded";
                [HUD hide:YES afterDelay:2];           
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshPictures object:nil ];
                [AppDelegate openGallery];
                [self dismissModalViewControllerAnimated:YES];
                
                // prepare NSDictionary with details of sharing if Twitter or Facebook was checked
                if ([shareTwitter isOn] || [shareFacebook isOn]){
                    NSDictionary *responsePhoto = [response objectForKey:@"result"] ;
                    
                    // parameters from upload
                    NSArray *keys = [NSArray arrayWithObjects:@"url", @"title",@"type",nil];
                    NSArray *objects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@", [responsePhoto objectForKey:@"url"]], [NSString stringWithFormat:@"%@", [responsePhoto objectForKey:@"title"]],[shareTwitter isOn] ? @"Twitter" : @"Facebook", nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShareInformationToFacebookOrTwitter object:[NSDictionary dictionaryWithObjects:objects forKeys:keys] ];
                    
                }               
            });
            
        } 
    }];
    
    [asiRequest setFailedBlock:^{
        // convert the responseDate to the json string
        NSString *jsonString = [asiRequest responseString];
        
#ifdef DEVELOPMENT_ENABLED  
        NSLog(@"Request failed to upload picture = %@",jsonString);       
#endif 
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // progress bar
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = @"Error";
            [HUD hide:YES afterDelay:2];
            
            
            NSError *error = [asiRequest error];
            NSLog(@"Error to upload = %@",[error localizedDescription]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request failed" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            // ATTENTION: remove the file form the local system. It was used only to create the multipart
            if (    self.fileNameToDelete  != nil){
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([fileManager fileExistsAtPath:    self.fileNameToDelete ]) {
                    BOOL __unused removeResult = NO;
                    NSError *error = nil;
                    removeResult = [fileManager removeItemAtPath:    self.fileNameToDelete  error:&error];
                }  
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshPictures object:nil ];
            
            OpenPhotoAppDelegate *appDelegate = (OpenPhotoAppDelegate*) [[UIApplication sharedApplication]delegate];
            [appDelegate openGallery];
            
            [self dismissModalViewControllerAnimated:YES];
        });
        
    }];
    
    [asiRequest startAsynchronous];
    
    [token release];
    [consumer release];
    [oaUrlRequest release];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    [image release];
    if (error.localizedDescription != nil){
        NSLog(@"Image could not be saved = %@", error.localizedDescription);
    }else{
        NSLog(@"Image saved");
    }
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
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
    [self.service release];
    [self.fileNameToDelete release];
    
    [super dealloc];
}

@end

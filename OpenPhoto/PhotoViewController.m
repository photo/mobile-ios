//
//  PhotoViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 29/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController()
-(void) uploadPicture:(NSDictionary*) values;
@end

@implementation PhotoViewController

@synthesize detailsPictureTable;
@synthesize imageOriginal,imageFiltered;
@synthesize titleTextField, descriptionTextField, permissionPicture, highResolutionPicture, gpsPosition;
@synthesize tagController, sourceType;
@synthesize location, service;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil photo:(UIImage *) imageFromPicker source:(UIImagePickerControllerSourceType) pickerSourceType
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.imageOriginal = imageFromPicker;
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
    
    coreLocationController = [[CoreLocationController alloc] init];
    coreLocationController.delegate = self;
    
    [super viewDidLoad];
}

- (void) cancelUploadButton{
    [self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidUnload{
    [super viewDidUnload];
    [imageTitle release];
    imageTitle = nil;
    [imageDescription release];
    imageDescription = nil;
    [self setDetailsPictureTable:nil];
    [coreLocationController release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    [image release];
    if (error.localizedDescription != nil){
        NSLog(@"Image could not be saved = %@", error.localizedDescription);
    }else{
        NSLog(@"Image saved");
    }
}

- (void) notifyUserNoInternet{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // problem with internet, show message to user
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet error" message:@"Couldn't reach the server. Please, check your internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}


#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section{
    return kNumbersRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    
    NSUInteger row = [indexPath row];
    switch (row) {
        case 0:
            // title
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierTitle];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierTitle] autorelease];
                titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(17 , 13, 260, 21)];
                titleTextField.adjustsFontSizeToFitWidth = YES;
                titleTextField.textColor = [UIColor grayColor];
                
                titleTextField.placeholder = @"title";
                titleTextField.keyboardType = UIKeyboardTypeDefault;
                titleTextField.returnKeyType = UIReturnKeyDone;
                titleTextField.delegate = self;
                titleTextField.backgroundColor = [UIColor whiteColor];
                [cell addSubview:titleTextField];
            }
            break;
        case 1:
            // description
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierDescription];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierDescription] autorelease];
                
                descriptionTextField = [[UITextField alloc] initWithFrame:CGRectMake(17 , 13, 260, 21)];
                descriptionTextField.adjustsFontSizeToFitWidth = YES;
                descriptionTextField.textColor = [UIColor grayColor];
                
                descriptionTextField.placeholder = @"description";
                descriptionTextField.keyboardType = UIKeyboardTypeDefault;
                descriptionTextField.returnKeyType = UIReturnKeyDone;
                descriptionTextField.delegate = self;
                
                descriptionTextField.backgroundColor = [UIColor whiteColor];
                [cell addSubview:descriptionTextField];                
            }
            break;
        case 2:
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
        case 3:
            // filter: disclosure button
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierFilter];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierFilter] autorelease];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"Crop & effects";
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            break;
            
        case 4:
            // high resolution picture
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierHighResolutionPicture];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierHighResolutionPicture] autorelease];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"High resolution";
            highResolutionPicture = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
            cell.accessoryView = highResolutionPicture;
            
            // get from user if picture will be uploaded in high resolution or not
            [(UISwitch *)cell.accessoryView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"photos_high_resolution"]];
            break;
            
        case 5:
            // private flag
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierPrivate];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierPrivate] autorelease];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"Private";
            permissionPicture = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
            cell.accessoryView = permissionPicture;
            
            // get from user configuration if pictures should be private or not
            [(UISwitch *)cell.accessoryView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"photos_are_private"]];
            break;
            
        case 6:
            // gps position
            // private flag
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierGpsPosition];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierGpsPosition] autorelease];
            }
            
            cell.textLabel.text=@"GPS Position";
            self.gpsPosition = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
            [self.gpsPosition addTarget:self action:@selector(switchedGpsPosition) forControlEvents:UIControlEventValueChanged];	
            cell.accessoryView = self.gpsPosition;
            
            // get from user configuration if pictures should be private or not
            [(UISwitch *)cell.accessoryView setOn:NO];
            break;
            
        default:
            break;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    if ( row == 3){
        // filter
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:0];
        AFFeatherController *controller = [[AFFeatherController alloc]
                                           initWithImage:self.imageOriginal];
        controller.delegate = self;
        
        [self presentModalViewController:controller animated:YES];
        [controller release];
    }else if (row == 2){
        // tags
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:0];
        [self.navigationController pushViewController:self.tagController animated:YES];
    }
}

-(void) switchedGpsPosition{
    // get gps position
    if ([self.gpsPosition isOn]){
        [coreLocationController.locMgr startUpdatingLocation];
        NSLog(@"Start Updating Location");
    }else{
        // stop gps position
        [coreLocationController.locMgr stopUpdatingLocation];
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

- (void)locationUpdate:(CLLocation *)position{
    self.location = position;
}

- (void)locationError:(NSError *)error {
    NSLog(@"Location %@", [error description]);
}


- (IBAction)upload:(id)sender {
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Upload button clicked");
#endif
    
    // title
    NSString *title = (titleTextField.text.length > 0 ? titleTextField.text : @"");
    
    // description
    NSString *description = (descriptionTextField.text.length > 0 ? descriptionTextField.text : @"");
    
    // default permission for the pictures is PUBLIC
    NSString *defaultPermission = @"1";
    
    if ([permissionPicture isOn]){
        defaultPermission = @"0";
    }
    
    NSString *latitude =@"";
    NSString *longitude=@"";
    
    if (self.location != nil){
        latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
        longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    }
    
    // check the size of the image
    if (![highResolutionPicture isOn]){
        CGSize sz = CGSizeMake(imageOriginal.size.width/2,imageOriginal.size.height/2);
        self.imageOriginal = [ImageManipulation imageWithImage:imageOriginal scaledToSize:sz];
        
        if (self.imageFiltered != nil){ 
            CGSize sz = CGSizeMake(imageFiltered.size.width/2,imageFiltered.size.height/2);
            self.imageFiltered = [ImageManipulation imageWithImage:imageFiltered scaledToSize:sz];
        }
    }
    
    // parameters to upload
    NSArray *keys = [NSArray arrayWithObjects:@"image", @"title", @"description", @"permission",@"exifCameraMake",@"exifCameraModel",@"tags",@"latitude",@"longitude",nil];
    NSArray *objects;
    
    // set the correct image to upload depends if there is a filtered or not.
    
    if (self.imageFiltered != nil){
        objects = [NSArray arrayWithObjects:self.imageFiltered, title, description, defaultPermission, @"Apple",[[UIDevice currentDevice] model],[tagController getSelectedTagsInJsonFormat],latitude,longitude, nil];
    } else{
        objects = [NSArray arrayWithObjects:self.imageOriginal, title, description, defaultPermission, @"Apple",[[UIDevice currentDevice] model],[tagController getSelectedTagsInJsonFormat],latitude,longitude, nil]; 
    }
    
    NSDictionary *values = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    // just save if it cames from the camera.
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera){
        // save picture local
        if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"photos_save_camera_roll_or_snapshot"] == YES){
            NSLog(@"Saving picture in the photo album");
            UIImageWriteToSavedPhotosAlbum([self.imageOriginal retain], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
        
        // save filtered picture local
        if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"photos_save_camera_roll_or_snapshot"] == YES && self.imageFiltered != nil){
            UIImageWriteToSavedPhotosAlbum([self.imageFiltered retain], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Will start uploading");
#endif
    
    HUD = [[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES] retain];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText=@"Preparing";
    
    if (service.internetActive == YES && service.hostActive == YES){
        // send the pictures in a asynchronus way
        [NSThread detachNewThreadSelector:@selector(uploadPictureOnDetachTread:) 
                                 toTarget:self 
                               withObject:values];
    }else{
        NSLog(@"Error, no internet connection");
    }
    
    // stop gps position
    [coreLocationController.locMgr stopUpdatingLocation];
}

// For upload
-(void) uploadPictureOnDetachTread:(NSDictionary*) values{
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Inside method upload");
#endif
    if (service.internetActive == YES && service.hostActive == YES){
        // send message to the site. it is pickedImage
        NSData *imageData = UIImageJPEGRepresentation([values objectForKey:@"image"] ,0.7);
        //Custom implementations, no built in base64 or HTTP escaping for iPhone
        NSString *imageB64   = [QSStrings encodeBase64WithData:imageData]; 
        NSString* imageEscaped = [Base64Utilities fullEscape:imageB64];
        
        // set all details to send
        NSString *uploadCall = [NSString stringWithFormat:@"photo=%@&title=%@&description=%@&permission=%@&exifCameraMake=%@&exifCameraModel=%@&tags=%@&latitude=%@&longitude=%@",imageEscaped,[values objectForKey:@"title"],[values objectForKey:@"description"],[values objectForKey:@"permission"],[values objectForKey:@"exifCameraMake"],[values objectForKey:@"exifCameraModel"], [values objectForKey:@"tags"],[values objectForKey:@"latitude"],[values objectForKey:@"longitude"]];
        
        NSMutableString *urlString =     [NSMutableString stringWithFormat: @"%@/photo/upload.json", 
                                          [[NSUserDefaults standardUserDefaults] stringForKey:kOpenPhotoServer]];
        
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Url upload = [%@]",urlString);
#endif
        
        // transform in URL for the request
        NSURL *url = [NSURL URLWithString:urlString];
        
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
        
        // prepare the request for body        
        [oaUrlRequest prepare];
        
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Token created, request ready to be sent");
#endif        
        [self performSelectorOnMainThread:@selector(uploadPicture:) withObject:oaUrlRequest waitUntilDone:YES];
        
        [token release];
        [consumer release];
        [oaUrlRequest release];
        [pool release];
    }
}

-(void) uploadPicture:(OAMutableURLRequest*) oaUrlRequest{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Sending request");
#endif
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.labelText = @"Sending";
    currentLength = 0;
    responseData = [[NSMutableData data] retain];
    [[NSURLConnection alloc] initWithRequest:oaUrlRequest delegate:self startImmediately:YES];
}

- (void) connection:(NSURLConnection*) connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    expectedLength = totalBytesExpectedToWrite;
    currentLength += totalBytesWritten;
    
	HUD.progress = totalBytesWritten / (float)expectedLength;
    
    if (HUD.progress == 1.0){
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.labelText = @"Finalization";
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection Failed: %@", [error description]);
    [HUD hide:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0]; 
    HUD.mode = MBProgressHUDModeDeterminate;
    expectedLength = [response expectedContentLength];
	currentLength = 0;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [connection release];
    
    // convert the responseDate to the json string
    NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    // it can be released
    [responseData release];
    
#ifdef DEVELOPMENT_ENABLED        
    NSLog(@"jsonString = %@",jsonString);       
#endif 
    
    // Create a dictionary from JSON string
    // When there are newline characters in the JSON string, 
    // the error "Unescaped control character '0x9'" will be thrown. This removes those characters.
    jsonString =  [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSDictionary *response =  [jsonString JSONValue]; 
    [jsonString release];
    
    // check if message is valid
    if (![WebService isMessageValid:response]){
        NSString* message = [WebService getResponseMessage:response];
        NSLog(@"Invalid response = %@",message);
        
        // show alert to user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Response Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
#ifdef TEST_FLIGHT_ENABLED
    [TestFlight passCheckpoint:@"Picture uploaded"];
#endif
    
    // progress bar
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"Uploaded";
    [HUD hide:YES afterDelay:2];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshPictures object:nil ];
        
    OpenPhotoAppDelegate *appDelegate = (OpenPhotoAppDelegate*) [[UIApplication sharedApplication]delegate];
    [appDelegate openGallery];
                                                    
    [self dismissModalViewControllerAnimated:YES];
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
    [imageDescription release];
    [imageOriginal release];
    [imageFiltered release];
    [detailsPictureTable release];
    [titleTextField release];
    [descriptionTextField release];
    [permissionPicture release];
    [highResolutionPicture release];
    [gpsPosition release];
    [self.service release];
    [coreLocationController release];
    [location release];
    [super dealloc];
}

@end

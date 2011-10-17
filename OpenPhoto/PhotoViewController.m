//
//  PhotoViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 29/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController()
// all details 
-(void) uploadPictureOnDetachTread:(NSDictionary*) values;
@end



@implementation PhotoViewController

@synthesize detailsPictureTable;
@synthesize statusBar;
@synthesize imageOriginal,imageFiltered;
@synthesize titleTextField, descriptionTextField, permissionPicture, highResolutionPicture;
@synthesize tagController, sourceType;
@synthesize service;

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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{   statusBar.hidden = YES;  
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // if user wants to cancel the upload
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelUploadButton)];          
    self.navigationItem.rightBarButtonItem = cancelButton;
    [cancelButton release];
    
    [super viewDidLoad];
}

- (void) cancelUploadButton
{
    [self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidUnload
{
    [imageTitle release];
    imageTitle = nil;
    [imageDescription release];
    imageDescription = nil;
    [statusBar release];
    statusBar = nil;
    
    [self setStatusBar:nil];
    [self setDetailsPictureTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)upload:(id)sender {
    statusBar.hidden = NO;
    [statusBar startAnimating];
    
    // title
    NSString *title = (titleTextField.text.length > 0 ? titleTextField.text : @"");
    
    // description
    NSString *description = (descriptionTextField.text.length > 0 ? descriptionTextField.text : @"");
    
    // default permission for the pictures is PUBLIC
    NSString *defaultPermission = @"1";
    
    if ([permissionPicture isOn]){
        defaultPermission = @"0";
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
    NSArray *keys = [NSArray arrayWithObjects:@"image", @"title", @"description", @"permission",@"exifCameraMake",@"exifCameraModel",@"tags",nil];
    NSArray *objects;
    
    // set the correct image to upload depends if there is a filtered or not.
    
    if (self.imageFiltered != nil){
        objects = [NSArray arrayWithObjects:self.imageFiltered, title, description, defaultPermission, @"Apple",[[UIDevice currentDevice] model],[tagController getSelectedTagsInJsonFormat], nil];
    } else{
        objects = [NSArray arrayWithObjects:self.imageOriginal, title, description, defaultPermission, @"Apple",[[UIDevice currentDevice] model],[tagController getSelectedTagsInJsonFormat], nil]; 
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
    
    // to send the request we add a thread.
    [NSThread detachNewThreadSelector:@selector(uploadPictureOnDetachTread:) 
                             toTarget:self 
                           withObject:values];
}

-(void) uploadPictureOnDetachTread:(NSDictionary*) values
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self.service uploadPicture:values];
    
#ifdef TEST_FLIGHT_ENABLED
    [TestFlight passCheckpoint:@"Picture uploaded"];
#endif
    
    [pool release];
}

// delegate
-(void) receivedResponse:(NSDictionary *)response{
    [statusBar stopAnimating];
    statusBar.hidden = YES;
    
    // check if message is valid
    if (![WebService isMessageValid:response]){
        NSString* message = [WebService getResponseMessage:response];
        NSLog(@"Invalid response = %@",message);
        
        // show alert to user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Response Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [self dismissModalViewControllerAnimated:YES];
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

- (void)dealloc {
    [imageTitle release];
    [imageDescription release];
    [statusBar release];
    [imageOriginal release];
    [imageFiltered release];
    [statusBar release];
    [detailsPictureTable release];
    [titleTextField release];
    [descriptionTextField release];
    [permissionPicture release];
    [highResolutionPicture release];
    [self.service release];
    [super dealloc];
}

@end

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
@synthesize titleTextField;
@synthesize descriptionTextField;
@synthesize permissionPicture;
@synthesize highResolutionPicture;
@synthesize tagController;
@synthesize sourceType;


static NSString *cellIdentifierTitle = @"cellIdentifierTitle";
static NSString *cellIdentifierDescription = @"cellIdentifierDescription";
static NSString *cellIdentifierTags=@"cellIdentifierTags";
static NSString *cellIdentifierFilter=@"cellIdentifierFilter";
static NSString *cellIdentifierPrivate=@"cellIdentifierPrivate";
static NSString *cellIdentifierHighResolutionPicture=@"cellHighResolutionPicture";


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
    [super viewDidLoad];
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
    [super dealloc];
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
    
    // send message to the site. it is pickedImage
    NSData *imageData = UIImageJPEGRepresentation([values objectForKey:@"image"] ,0.7);
    //Custom implementations, no built in base64 or HTTP escaping for iPhone
    NSString *imageB64   = [QSStrings encodeBase64WithData:imageData]; 
    NSString* imageEscaped = [Base64Utilities pictureEscape:imageB64];
    
    
    // set all details to send
    NSString *uploadCall = [NSString stringWithFormat:@"photo=%@&title=%@&description=%@&permission=%@&exifCameraMake=%@&exifCameraModel=%@&tags=%@",imageEscaped,[values objectForKey:@"title"],[values objectForKey:@"description"],[values objectForKey:@"permission"],[values objectForKey:@"exifCameraMake"],[values objectForKey:@"exifCameraModel"], [values objectForKey:@"tags"]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://current.openphoto.me/photo/upload.json"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d",[uploadCall length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:[uploadCall dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]];
    
    
    NSURLResponse *response;
    NSError *error = nil;
    
    NSData *XMLResponse= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
	NSString *jsonString = [[NSString alloc] initWithData:XMLResponse encoding:NSUTF8StringEncoding];
    NSLog(@"Result = %@",jsonString);   
    
    [statusBar stopAnimating];
    statusBar.hidden = YES;
    
    [self dismissModalViewControllerAnimated:YES];
    [pool release];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    [image release];
    if (error.localizedDescription != nil){
        NSLog(@"Image could not be saved = %@", error.localizedDescription);
    }else{
        NSLog(@"Image saved");
    }
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
            cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifierTitle];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierTitle] autorelease];
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
            cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifierDescription];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierDescription] autorelease];
                
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
            cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifierTags];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierTags] autorelease];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"Tags";
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            break;
        case 3:
            // filter: disclosure button
            cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifierFilter];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierFilter] autorelease];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=@"Filter";
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            break;
            
        case 4:
            // high resolution picture
            cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifierHighResolutionPicture];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierHighResolutionPicture] autorelease];
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
            cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifierPrivate];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierPrivate] autorelease];
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
    
    NSLog(@"Value row = %d",row);
    
    if ( row == 3){
        // filter
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:0];
        FilterViewController *filter = [[[FilterViewController alloc] initWithNibName:@"FilterViewController" bundle:nil]autorelease];
        [self.navigationController pushViewController:filter animated:YES];
    }else if (row == 2){
        // tags
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:0];
        [self.navigationController pushViewController:self.tagController animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end

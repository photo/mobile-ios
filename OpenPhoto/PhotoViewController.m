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
@synthesize imageToSend;
@synthesize titleTextField;
@synthesize descriptionTextField;
@synthesize permissionPicture;


static NSString *cellIdentifierTitle = @"cellIdentifierTitle";
static NSString *cellIdentifierDescription = @"cellIdentifierDescription";
static NSString *cellIdentifierTags=@"cellIdentifierTags";
static NSString *cellIdentifierFilter=@"cellIdentifierFilter";
static NSString *cellIdentifierPrivate=@"cellIdentifierPrivate";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil photo:(UIImage *) imageFromPicker
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        imageToSend = imageFromPicker;
        // it will be necessary to send the 
        [imageToSend retain];
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
{        statusBar.hidden = YES;  
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
    [imageToSend release];
    [statusBar release];
    [detailsPictureTable release];
    [titleTextField release];
    [descriptionTextField release];
    [permissionPicture release];
    [super dealloc];
}

- (IBAction)upload:(id)sender {
    statusBar.hidden = NO;
    [statusBar startAnimating];
    
    // default permission for the pictures is PUBLIC
    NSString *defaultPermission = @"1";
    
    if ([permissionPicture isOn]){
        defaultPermission = @"0";
    }
    
    NSArray *keys = [NSArray arrayWithObjects:@"image", @"title", @"description", @"permission",nil];
    NSArray *objects = [NSArray arrayWithObjects:imageToSend, titleTextField.text, descriptionTextField.text, defaultPermission, nil];
    
    NSDictionary *values = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
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
    NSString* imageEscaped = [OpenPhotoBase64Utilities pictureEscape:imageB64];
    
    
    // set all details to send
    NSString *uploadCall = [NSString stringWithFormat:@"photo=%@&title=%@&description=%@&permission=%@",imageEscaped,[values objectForKey:@"title"],[values objectForKey:@"description"],[values objectForKey:@"permission"] ];

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
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
            [(UISwitch *)cell.accessoryView setOn:NO];
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    
    NSUInteger row = [indexPath row];
    NSLog(@"Row clicked = %d",row);
    
    if ( row == 3){
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:0];
        FilterViewController *filter = [[[FilterViewController alloc] initWithNibName:@"FilterViewController" bundle:nil]autorelease];
        [self.navigationController pushViewController:filter animated:YES];
    }  
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end

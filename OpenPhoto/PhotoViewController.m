//
//  PhotoViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 28/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController()
- (void) openTypePhotoLibrary;    
- (void) openTypeCamera;
@end

@implementation PhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (void) viewWillAppear:(BOOL)animated
{
    // check if user has camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Upload your picture" delegate:self cancelButtonTitle:@"Cancel Button" destructiveButtonTitle:nil otherButtonTitles:@"Camera roll", @"Snapshot", nil];
        menu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [menu showInView:self.tabBarController.view];
        [menu release];
    }else{
        // open direct the library
        [self openTypePhotoLibrary];
    }
}

-(void) openTypePhotoLibrary{
    UIImagePickerController *pickerController = [[UIImagePickerController
                                                  alloc]
                                                 init];
    pickerController.sourceType =
    UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    [self presentModalViewController:pickerController animated:YES];
    [pickerController release]; 
}

-(void) openTypeCamera{
    UIImagePickerController *pickerController = [[UIImagePickerController
                                                  alloc]
                                                 init];
    pickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
    pickerController.delegate = self;
    [self presentModalViewController:pickerController animated:YES];
    [pickerController release];
}


// user can open the photo library or the camera. Ask him.
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self openTypePhotoLibrary];
    } else if (buttonIndex == 1) {
        [self openTypeCamera];
    } 
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{    
    // progress
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect size = CGRectMake(130,100,50,50);
    [indicator setFrame:size];
    [indicator startAnimating];
    indicator.hidesWhenStopped=YES;
    [self.view addSubview:indicator];
    
    UIImage *pickedImage = [info
                            objectForKey:UIImagePickerControllerOriginalImage];
    
    //show
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    
    // send message to the site. it is pickedImage
    NSData *imageData = UIImageJPEGRepresentation(pickedImage,0.7);
    //Custom implementations, no built in base64 or HTTP escaping for iPhone
    NSString *imageB64   = [QSStrings   encodeBase64WithData:imageData]; 
    
    
    NSMutableString *escaped = [NSMutableString stringWithString:[imageB64 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];   
    [escaped replaceOccurrencesOfString:@"+" withString:@"%2B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    
    /**
     [escaped replaceOccurrencesOfString:@"$" withString:@"%24" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
     [escaped replaceOccurrencesOfString:@"&" withString:@"%26" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
     [escaped replaceOccurrencesOfString:@"," withString:@"%2C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
     [escaped replaceOccurrencesOfString:@":" withString:@"%3A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
     [escaped replaceOccurrencesOfString:@";" withString:@"%3B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
     [escaped replaceOccurrencesOfString:@"=" withString:@"%3D" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
     [escaped replaceOccurrencesOfString:@"?" withString:@"%3F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
     [escaped replaceOccurrencesOfString:@"@" withString:@"%40" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
     [escaped replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
     [escaped replaceOccurrencesOfString:@"\t" withString:@"%09" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
     [escaped replaceOccurrencesOfString:@"#" withString:@"%23" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
     [escaped replaceOccurrencesOfString:@"<" withString:@"%3C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
     [escaped replaceOccurrencesOfString:@">" withString:@"%3E" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
     [escaped replaceOccurrencesOfString:@"\"" withString:@"%22" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
     [escaped replaceOccurrencesOfString:@"\n" withString:@"%0A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
     */
    
    
    NSString *uploadCall = [NSString stringWithFormat:@"photo=%@",escaped];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://current.openphoto.me/photo/upload.json"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d",[uploadCall length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:[uploadCall dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]];
    
    
    NSURLResponse *response;
    NSError *error = nil;
    
    NSData *XMLResponse= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
	NSString *jsonString = [[NSString alloc] initWithData:XMLResponse encoding:NSUTF8StringEncoding];
    NSLog(@"Result = %@",jsonString);   
    
    // don't show
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [indicator stopAnimating];
    [indicator release];
    
    // Show user a message
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Image uploaded" 
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    [picker dismissModalViewControllerAnimated:YES];
}

-(void) dealloc{
    
    [super dealloc];
}
@end

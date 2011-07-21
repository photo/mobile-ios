#import "LauncherController.h"

@implementation LauncherController

- (void)loadView {
    [super loadView];
    
    self.title = @"Open Photo Mobile";
    self.navigationItem.rightBarButtonItem =
    [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                     target:self
                                     action:@selector(openPickerFromButton)] autorelease];

    
    launcherView = [[TTLauncherView alloc] initWithFrame:self.view.bounds];
    launcherView.delegate = self;
    launcherView.pages = [NSArray arrayWithObjects:
                          [NSArray arrayWithObjects:
                           [[[TTLauncherItem alloc] initWithTitle:@"Gallery"
                                                            image:@"bundle://Icon-72.png"
                                                              URL:@"openphoto://gallery" canDelete:NO] autorelease],
                           [[[TTLauncherItem alloc] initWithTitle:@"Website"
                                                           image:@"bundle://Icon-72.png"
                                                              URL:@"http://openphoto.me" canDelete:NO] autorelease],
                           nil],
                          nil];
    
    launcherView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:launcherView];    
}


- (void)launcherView:(TTLauncherView*)launcher didSelectItem:(TTLauncherItem*)item {
    [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:item.URL]];
}

- (void) openPickerFromButton{
    NSLog(@"Get pictures");
    UIImagePickerController *pickerController = [[UIImagePickerController
                                                  alloc]
                                                 init];
    pickerController.sourceType =
    UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    [self presentModalViewController:pickerController animated:YES];
    [pickerController release];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickedImage = [info
                            objectForKey:UIImagePickerControllerOriginalImage];
   
    // send message to the site. it is pickedImage
    NSData *imageData = UIImageJPEGRepresentation(pickedImage, 1);
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:@"http://current.openphoto.me/photo/upload.json"]];
    [request setHTTPMethod:@"POST"];

    NSString *stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
//    NSMutableData *body = [NSMutableData data];
//    [body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; title=\"Patrick Teste\"; filename=\"photo.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:imageData];
//    
//    [request setHTTPBody:body];
    
    NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[NSData dataWithData:UIImageJPEGRepresentation(pickedImage,1)]];
    
    [request setHTTPBody:postBody];

    NSLog(@"%@", [request allHTTPHeaderFields]);
     NSLog(@"%@",[request valueForHTTPHeaderField:contentType]);
    

//    NSString *imageB64   = [self escapeString:[imageDatabase64Encoding]];  
//Custom implementations, no built in base64 or HTTP escaping for iPhone
    
    [self dismissModalViewControllerAnimated:YES];

    
    NSURLResponse *response;
    NSError *error = nil;
    NSData *XMLResponse = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];   
	NSString *jsonString = [[NSString alloc] initWithData:XMLResponse encoding:NSUTF8StringEncoding];
    NSLog(@"Result = %@",jsonString);   
        

}

@end

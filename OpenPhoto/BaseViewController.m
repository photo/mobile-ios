//
//  BaseViewController.m
//  RaisedCenterTabBar
//
//  Created by Peter Boctor on 12/15/10.
//
// Copyright (c) 2011 Peter Boctor
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//

#import "BaseViewController.h"

@interface BaseViewController()
- (void) openTypePhotoLibrary;    
- (void) openTypeCamera;
@end

@implementation BaseViewController

// Create a view controller and setup it's tab bar item with a title and image
-(UIViewController*) viewControllerWithTabTitle:(NSString*) title image:(UIImage*)image
{
   
   // Here we keep the link of what is in the BAR and its Controllers
    if (title == @"Home"){
        
    }else if (title == @"Gallery"){
        GalleryViewController *controller = [[[GalleryViewController alloc]init] autorelease];
        controller.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:image tag:0] autorelease];
        UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
        return navController;
    }else if (title == @"Tags"){
        
    }else if (title == @"Settings"){
        
    }
    
    
    UIViewController* viewController = [[[UIViewController alloc] init] autorelease];
    viewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:image tag:0] autorelease];
    return viewController;
}


// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    
    if (heightDifference < 0){
        button.center = self.tabBar.center;
    }else{
        CGPoint center = self.tabBar.center;
        center.y =self.tabBar.frame.size.height-(buttonImage.size.height/2.0);
        button.center = center;
    }
    
    // action for this button
    [button addTarget:self action:@selector(buttonEvent) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tabBar addSubview:button];
}

-(void)buttonEvent{
    
    
    ///
    /// NEEDS REFACTORING
    ///
    ///
    // check if user has camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Upload your picture" delegate:self cancelButtonTitle:@"Cancel Button" destructiveButtonTitle:nil otherButtonTitles:@"Camera roll", @"Snapshot", nil];
        menu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [menu showInView:self.view];
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
    NSString *imageB64   = [QSStrings encodeBase64WithData:imageData]; 
    
    
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

// user can open the photo library or the camera. Ask him.
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self openTypePhotoLibrary];
    } else if (buttonIndex == 1) {
        [self openTypeCamera];
    } 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)dealloc {
    [super dealloc];
}
@end

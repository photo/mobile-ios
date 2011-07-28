//
//  GalleryViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 11/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "GalleryViewController.h"

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Private interface definitions
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
@interface GalleryViewController()
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)searchPhotos;
@end


@implementation GalleryViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.view.backgroundColor = [UIColor blackColor];
        self.tabBarItem.image=[UIImage imageNamed:@"tab-gallery.png"];
        self.title=@"Gallery";
        self.hidesBottomBarWhenPushed = NO;
        self.wantsFullScreenLayout = YES;
                
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self searchPhotos];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [connection release];
    
    // convert the responseDate to the json string
    NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    // it can be released
    [responseData release];
    
    // Create a dictionary from JSON string
    // When there are newline characters in the JSON string, 
    // the error "Unescaped control character '0x9'" will be thrown. This removes those characters.
    jsonString =  [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSDictionary *results =  [jsonString JSONValue];
    
    // Build an array with all photos from the dictionary.
    NSArray *photos = [results objectForKey:@"result"] ;
    
    NSMutableArray *mockPhotos = [[NSMutableArray alloc] init];
    
    // Loop through each entry in the dictionary and create an array of MockPhoto
    for (NSDictionary *photo in photos){
        // Get title of the image
        NSString *title = [photo objectForKey:@"Name"];
        
        // print the title and url. If no name, add Untitled.
        NSLog(@"All details %@",photo);
        NSLog(@"Photo Title: %@", (title.length > 0 ? title : @"Untitled"));
        NSString *photoURLString = [NSString stringWithFormat:@"http://%@%@", [photo objectForKey:@"host"], [photo objectForKey:@"path200x200"]];
        NSLog(@"Photo url: %@ \n\n", photoURLString);
        
        float width = [[photo objectForKey:@"width"] floatValue];
        float height = [[photo objectForKey:@"height"] floatValue];
        
        // calculate the real size of the image. It will keep the aspect ratio.
        float realWidth = 0;
        float realHeight = 0;
        
        if(width/height >= 1) { 
            // portrait or square
            realWidth = 640;
            realHeight = height/width*640;
        } else { 
            // landscape
            realHeight = 960;
            realWidth = width/height*960;
        }
        
        [mockPhotos addObject: [[[MockPhoto alloc]
                                 initWithURL:[NSString stringWithFormat:@"%@", [photo objectForKey:@"path640x960"]]
                                 smallURL:[NSString stringWithFormat:@"%@",[photo objectForKey:@"path200x200"]]
                                 size:CGSizeMake(realWidth, realHeight)] autorelease]];
    } 
    
    self.photoSource = [[MockPhotoSource alloc]
                        initWithType:MockPhotoSourceNormal
                        title:@"Gallery"
                        photos:mockPhotos
                        photos2:nil];
    
    // this is for the loading
    //  photos2:nil
    // photos2:[[NSArray alloc] initWithObjects:
    //          [[[MockPhoto alloc]
    //            initWithURL:@"http://farm4.static.flickr.com/3280/2949707060_e639b539c5_o.jpg"
    //            smallURL:@"http://farm4.static.flickr.com/3280/2949707060_8139284ba5_t.jpg"
    //            size:CGSizeMake(800, 533)] autorelease],
    //          nil]
    // ];
    
    [mockPhotos autorelease];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (void)searchPhotos{
    //show
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // create the url to connect to OpenPhoto
    NSString *urlString = @"http://current.openphoto.me/photos/pageSize-25.json?returnSizes=200x200,640x960";
    NSURL *url = [NSURL URLWithString:urlString];
    
    responseData = [[NSMutableData data] retain];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}


- (void) dealloc {
    [super dealloc];
}

@end

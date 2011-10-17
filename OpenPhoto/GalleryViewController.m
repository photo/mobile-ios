//
//  GalleryViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 11/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "GalleryViewController.h"

@implementation GalleryViewController
@synthesize service, tagName;

- (id)init{
    self = [super init];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor blackColor];
        self.tabBarItem.image=[UIImage imageNamed:@"tab-gallery.png"];
        self.tabBarItem.title=@"Gallery";
        self.title=@"Gallery";
        self.hidesBottomBarWhenPushed = NO;
        self.wantsFullScreenLayout = YES;
        
        // create service and the delegate
        self.service = [[WebService alloc]init];
        [service setDelegate:self];
        
        self.photoSource = [[MockPhotoSource alloc]
                            initWithTitle:@"Gallery"
                            photos:nil
                            photos2:nil];
    }
    return self;
}

- (id) initWithTagName:(NSString*) tag{
    self = [self init];
    if (self) {
        self.tagName = tag;
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if (self.tagName != nil){
        [service loadGallery:25 withTag:self.tagName];
    }else{
        [service loadGallery:25];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set the tile of the table
    self.title=@"Gallery";     
}

// delegate
-(void) receivedResponse:(NSDictionary *)response{
    // check if message is valid
    if (![WebService isMessageValid:response]){
        NSString* message = [WebService getResponseMessage:response];
        NSLog(@"Invalid response = %@",message);
        
        // show alert to user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Response Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    NSArray *responsePhotos = [response objectForKey:@"result"] ;
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    // result can be null
    if ([responsePhotos class] != [NSNull class]) {
        
        // Loop through each entry in the dictionary and create an array of MockPhoto
        for (NSDictionary *photo in responsePhotos){
            // Get title/description of the image
            
            NSString *title = [photo objectForKey:@"title"];
            NSString *description = [photo objectForKey:@"description"];
            
            NSString *photoURLString = [NSString stringWithFormat:@"http://%@%@", [photo objectForKey:@"host"], [photo objectForKey:@"path200x200"]];
            NSLog(@"Photo url [%@] with tile [%@] and description [%@]", photoURLString, (title.length > 0 ? title : @"Untitled"),(description.length > 0 ? description : @"Untitled"));
            
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
            
            [photos addObject: [[[Photo alloc]
                                     initWithURL:[NSString stringWithFormat:@"%@", [photo objectForKey:@"path640x960"]]
                                     smallURL:[NSString stringWithFormat:@"%@",[photo objectForKey:@"path200x200"]] 
                                     size:CGSizeMake(realWidth, realHeight) caption:title] autorelease]];
        } }
    
    self.photoSource = [[MockPhotoSource alloc]
                        initWithTitle:@"Gallery"
                        photos:photos
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
    
    [photos autorelease];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
#ifdef TEST_FLIGHT_ENABLED
    [TestFlight passCheckpoint:@"Gallery Loaded"];
#endif
    
}

- (void) notifyUserNoInternet{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // problem with internet, show message to user
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet error" message:@"Couldn't reach the server. Please, check your internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void) dealloc {
    [service release];
    [tagName release];
    [super dealloc];
}

@end

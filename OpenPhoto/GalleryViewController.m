//
//  GalleryViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 11/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "GalleryViewController.h"

@implementation GalleryViewController
@synthesize service;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
        
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSLog(@"Value service=%@",service);
    [service loadGallery:25];
    
}

// delegate
-(void) receivedResponse:(NSDictionary *)response{
    NSArray *photos = [response objectForKey:@"result"] ;
    NSMutableArray *mockPhotos = [[NSMutableArray alloc] init];
    
    // Loop through each entry in the dictionary and create an array of MockPhoto
    for (NSDictionary *photo in photos){
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
        
        [mockPhotos addObject: [[[MockPhoto alloc]
                                 initWithURL:[NSString stringWithFormat:@"%@", [photo objectForKey:@"path640x960"]]
                                 smallURL:[NSString stringWithFormat:@"%@",[photo objectForKey:@"path200x200"]] 
                                 size:CGSizeMake(realWidth, realHeight) caption:title] autorelease]];
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

- (void) dealloc {
    [service release];
    [super dealloc];
}

@end

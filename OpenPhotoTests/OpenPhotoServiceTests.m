//
//  OpenPhotoServiceTests.m
//  OpenPhoto
//
//  Created by Patrick Santana on 29/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "OpenPhotoServiceTests.h"

@implementation OpenPhotoServiceTests


// test fetch
-(void) testFetch{
    OpenPhotoService *service = [OpenPhotoServiceFactory createOpenPhotoService];
    if (![[service fetchNewestPhotosMaxResult:5] count] > 0){
        STFail(@"We should have some newest photos");
    }
}

// test upload form
-(void) testUploadPhoto{
    OpenPhotoService *service = [OpenPhotoServiceFactory createOpenPhotoService];
    
    NSArray *keys = [NSArray arrayWithObjects: @"title", @"permission",@"tags",nil];
    NSArray *objects = [NSArray arrayWithObjects:@"Image from iPhone unit test", [NSNumber numberWithBool:YES], @"", nil];   
    NSDictionary *values = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    // load a test image
    NSData *image = UIImageJPEGRepresentation([UIImage imageNamed:@"unit_test_image.jpg"], 0.7);
    
    // send image
    [service uploadPicture:image metadata:values];
}
@end

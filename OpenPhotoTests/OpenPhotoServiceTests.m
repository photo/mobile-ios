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
    NSArray *objects = [NSArray arrayWithObjects:@"", [NSNumber numberWithBool:YES], @"", nil];   
    NSDictionary *values = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    // load a test image
    NSString *filePath = [[NSBundle bundleForClass:[OpenPhotoServiceTests class]] pathForResource:@"unit_test_image"  ofType:@"jpg"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];  
        
    // send image
    [service uploadPicture:data metadata:values fileName:@"unit_test.jpg"];
}

@end

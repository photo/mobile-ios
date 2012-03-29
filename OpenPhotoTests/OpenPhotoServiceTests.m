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
-(void) uploadPhoto{
    OpenPhotoService *service = [OpenPhotoServiceFactory createOpenPhotoService];
    [service fetchNewestPhotosMaxResult:5];
}
@end

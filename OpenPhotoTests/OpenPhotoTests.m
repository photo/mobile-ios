//
//  OpenPhotoTests.m
//  OpenPhotoTests
//
//  Created by Patrick Santana on 28/07/11.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "OpenPhotoTests.h"
#import "NewAccountService.h"


@implementation OpenPhotoTests

- (void)setUp{
    [super setUp];
}

- (void)tearDown{
    [super tearDown];
}

- (void)testAssetLibrary{
    NSString *asset=@"assets-library://asset/asset.JPG?id=1000000003&ext=JPG";
    NSURL *url = [NSURL URLWithString:asset];
    NSLog(@"Asset url = %@",asset);
    
    // get the extension
    NSString *extension = [AssetsLibraryUtilities getAssetsUrlExtension:url];
    if (! [extension isEqualToString:@"JPG"]){
        STFail(@"Extension should be JGP");
    }
    
    // get the id
    NSString *id = [AssetsLibraryUtilities getAssetsUrlId:url];
    if (! [id isEqualToString:@"1000000003"]){
        STFail(@"Extension should be 1000000003");
    }
}

-(void) testSHA1{
    NSString *result = [SHA1 sha1:@"openphoto project"];
    STAssertTrue([@"069aa3984c0c8d27ee405bc5e63024ac43f44615" isEqualToString:result], @"Incorrect SHA1");
}

@end

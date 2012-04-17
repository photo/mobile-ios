//
//  OpenPhotoTests.m
//  OpenPhotoTests
//
//  Created by Patrick Santana on 28/07/11.
//  Copyright 2012 OpenPhoto
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "OpenPhotoTests.h"

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

-(void) testSHA1File{
    NSString *filePath = [[NSBundle bundleForClass:[OpenPhotoTests class]] pathForResource:@"unit_test_image"  ofType:@"jpg"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];  

    NSString *result = [SHA1 sha1File:data];
    STAssertTrue([@"bfdf353630e91bab5647dba3b7d44a9bc9305588" isEqualToString:result], @"Incorrect SHA1");
}
@end

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

#import <Three20/Three20.h>
#import "Three20Core/NSArrayAdditions.h"
#import "WebService.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface PhotoSource : TTURLRequestModel <TTPhotoSource> {
    NSString* _title;
    NSMutableArray* photos;
    int numberOfPhotos;
    int currentPage;
    int actualMaxPhotoIndex;
    NSString* tagName;
    WebService* service;
}

@property (nonatomic, copy) NSString* tagName;
@property (nonatomic, retain) WebService *service;
@property (nonatomic, retain) NSMutableArray* photos;
@property (nonatomic) int currentPage,actualMaxPhotoIndex;

- (id)initWithTitle:(NSString*)title photos:(NSArray*)listPhotos size:(int) size tag:(NSString*) tag;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface Photo : NSObject <TTPhoto> {
    id<TTPhotoSource> _photoSource;
    NSString* _thumbURL;
    NSString* _smallURL;
    NSString* _URL;
    CGSize _size;
    NSInteger _index;
    NSString* _caption;
    NSString* pageUrl;
}

@property (nonatomic, copy) NSString *pageUrl;

- (id)initWithURL:(NSString*)URL smallURL:(NSString*)smallURL size:(CGSize)size page:(NSString*) page;

- (id)initWithURL:(NSString*)URL smallURL:(NSString*)smallURL size:(CGSize)size
          caption:(NSString*)caption page:(NSString*) page;

@end

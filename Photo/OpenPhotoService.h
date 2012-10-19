//
//  OpenPhotoService.h
//  Photo
//
//  Created by Patrick Santana on 20/03/12.
//  Copyright 2012 Photo
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

#import "ASIHTTPRequest.h"
#import "OAMutableURLRequest.h"
#import "OAToken.h"
#import "NSString+SBJSON.h"
#import "ASIFormDataRequest.h"
#import "ContentTypeUtilities.h"
#import "ASIProgressDelegate.h"
#import "ASIFormDataRequest.h"

@interface OpenPhotoService : NSObject{
    
}

- (id)initForServer:(NSString *) server 
           oAuthKey:(NSString *) oAuthKey 
        oAuthSecret:(NSString *) oAuthSecret 
        consumerKey:(NSString *) consumerKey 
     consumerSecret:(NSString *) consumerSecret;

- (NSArray*) fetchNewestPhotosMaxResult:(int) maxResult;

// in the dictionary, we expect: title, permission and tags
- (NSDictionary*) uploadPicture:(NSData*) data metadata:(NSDictionary*) values fileName:(NSString *)fileName delegate:(id) delegate;

// get all tags. It brings how many images have this tag.
- (NSArray*)  getTags; 

// get details from the system
- (NSArray*)  getSystemVersion;

// remove credentials form the server when log out
- (NSArray*)  removeCredentialsForKey:(NSString *) consumerKey;

// check via SHA1 is photo is already in the server
- (BOOL) isPhotoAlreadyOnServer:(NSString *) sha1;

+ (BOOL) isMessageValid:(NSDictionary *)response;

// get pictures to be used in the gallery
- (NSArray*) loadGallery:(int) pageSize onPage:(int) page;

// get pictures by tag
- (NSArray*) loadGallery:(int) pageSize withTag:(NSString*) tag onPage:(int) page;

// get albums with a specific page size
- (NSArray*) loadAlbums:(int) pageSize;

@end

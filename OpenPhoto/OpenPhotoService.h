//
//  OpenPhotoService.h
//  iPhone and iPad Example
//
//  Created by Patrick Santana on 20/03/12.
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

#import "ASIHTTPRequest.h"
#import "OAMutableURLRequest.h"
#import "OAToken.h"
#import "NSString+SBJSON.h"

@interface OpenPhotoService : NSObject{
    
}

+ (OpenPhotoService*) singletonForServer:(NSString *) server 
                                oAuthKey:(NSString *) oAuthKey 
                             oAuthSecret:(NSString *) oAuthSecret 
                             consumerKey:(NSString *) consumerKey 
                          consumerSecret:(NSString *) consumerSecret;

- (NSArray*) fetchNewestPhotosMaxResult:(int) maxResult;
- (void) uploadPicture:(NSData*) data metadata:(NSDictionary*) values filename:(NSString*) fileName fileToDelete:(NSString*) fileToDelete;



+ (BOOL) isMessageValid:(NSDictionary *)response;
+ (BOOL) isCredentialsValid;
+ (void) removeCredentials;
@end

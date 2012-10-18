//
//  AssetsLibraryUtilities.m
//  Photo
//
//  Created by Patrick Santana on 04/03/12.
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

#import "AssetsLibraryUtilities.h"

@interface AssetsLibraryUtilities()
+(NSDictionary*) parseAssetUrl:(NSURL*) url;
@end

@implementation AssetsLibraryUtilities


+ (NSString*) getAssetsUrlExtension:(NSURL*) url    {
    NSDictionary *pairs = [self parseAssetUrl:url];
    // return the ext
    return [pairs objectForKey:@"ext"];
}

+ (NSString*) getAssetsUrlId:(NSURL*) url{
    NSDictionary *pairs = [self parseAssetUrl:url];
    // return the ext
    return [pairs objectForKey:@"id"];
}

+ (NSDictionary*) parseAssetUrl:(NSURL*) url{
    NSString *query = [url query];
    NSArray *queryPairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
    for (NSString *queryPair in queryPairs) {
        NSArray *bits = [queryPair componentsSeparatedByString:@"="];
        if ([bits count] != 2) { continue; }
        
        NSString *key = [[bits objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *value = [[bits objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [pairs setObject:value forKey:key];
    }   
    
    return pairs;
}

+ (NSString *) getFileNameForImage:(NSData*)data 
                               url:(NSURL*) url
{
    if (!url){
        CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
        
        // get type of the file
        NSString *extension = [ContentTypeUtilities contentTypeExtensionForImageData:data];
        
        return [NSString stringWithFormat:@"%@.%@",(NSString *) newUniqueIdString,extension];
    }else{
        // no filter, image is located on Library
        return [NSString stringWithFormat:@"%@.%@",[AssetsLibraryUtilities getAssetsUrlId:url],[AssetsLibraryUtilities getAssetsUrlExtension:url]];
    }
}

@end

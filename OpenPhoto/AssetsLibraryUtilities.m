//
//  AssetsLibraryUtilities.m
//  OpenPhoto
//
//  Created by Patrick Santana on 04/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

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

@end

//
//  AssetsLibraryUtilities.m
//  Trovebox
//
//  Created by Patrick Santana on 04/03/12.
//  Copyright 2013 Trovebox
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

#import "AssetsLibraryUtilities.h"

@interface AssetsLibraryUtilities()
+(NSDictionary*) parseAssetUrl:(NSURL*) url;
+ (NSDate*) getDefaultFileDate:(NSURL*) url;
+ (NSDate*) getFileDate:(NSURL*) url;
@end

@implementation AssetsLibraryUtilities

NSString *const kExifDateFormat = @"yyyy:MM:dd HH:mm:ss";

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

+ (NSString *) getPhotoTitleForImage:(NSData*)data
                                 url:(NSURL*) url
{
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    NSDictionary *exif = (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
    
    // check if there is date, if not returns current date
    // in the exif we must look these values in the order:
    // {Exif} = DateTimeOriginal, DateTimeDigitized
    // {TIFF} = DateTime
    // date format = 2013:05:12 17:17:24
    
    // first we look for {Exif}
    NSDictionary *exifDetails = [exif objectForKey:@"{Exif}"];
    // get first DateTimeOriginal
    NSDate *date = [DateUtilities getDateFrom:[exifDetails objectForKey:@"DateTimeOriginal"] withFormat:kExifDateFormat];
    
    if (date == nil){
        // if it does not exist, let's try DateTimeDigitized
        date = [DateUtilities getDateFrom:[exifDetails objectForKey:@"DateTimeDigitized"] withFormat:kExifDateFormat];
        if (date == nil){
            // if it does not exist, get the {TIFF}
            NSDictionary *tiffDetails = [exif objectForKey:@"{TIFF}"];
            date = [DateUtilities getDateFrom:[tiffDetails objectForKey:@"DateTime"] withFormat:kExifDateFormat];
            
            if (date == nil){
                // if nothing works, get the default date
                date = [self getDefaultFileDate:url];
            }
        }
    }
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Date for file = %@",[[DateUtilities formatDate:date] stringByReplacingOccurrencesOfString:@":" withString:@"."]);
#endif
    
    return [[DateUtilities formatDate:date] stringByReplacingOccurrencesOfString:@":" withString:@"."];
}
+ (NSString*) getFileNameForImage:(NSData*)data
                              url:(NSURL*) url
{
    
    if (!url){
        CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
        
        // get type of the file
        NSString *extension = [ContentTypeUtilities contentTypeExtensionForImageData:data];
        
        return [NSString stringWithFormat:@"%@.%@",(__bridge NSString *) newUniqueIdString,extension];
    }else{
        // no filter, image is located on Library
        return [NSString stringWithFormat:@"%@.%@",[AssetsLibraryUtilities getAssetsUrlId:url],[AssetsLibraryUtilities getAssetsUrlExtension:url]];
    }
}

+ (NSDate*) getDefaultFileDate:(NSURL*) url
{
    // try to get the file date
    NSDate *fileDate = [self getFileDate:url];
    
    if (fileDate != nil){
        return fileDate;
    }
    
    // no information on file
    return [NSDate date];
}

+ (NSDate*) getFileDate:(NSURL*) url
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *attrs = [fm attributesOfItemAtPath:[url absoluteString] error:nil];
    
    if (attrs != nil) {
        return (NSDate*)[attrs objectForKey: NSFileCreationDate];
    }else {
        return nil;
    }
}

@end

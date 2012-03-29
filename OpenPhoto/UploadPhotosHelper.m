//
//  UploadPhotosHelper.m
//  OpenPhoto
//
//  Created by Patrick Santana on 29/03/12.
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

#import "UploadPhotosHelper.h"

@implementation UploadPhotosHelper


+ (NSString *) getFileNameForDictionary:(NSDictionary *) dictionary
{
    if ([(NSNumber*) [dictionary objectForKey:@"filtered"] boolValue]){
        // filtered
        CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
        
        // get type of the file
        NSData *data = [dictionary objectForKey:@"filteredImage"];
        NSString *extension = [ContentTypeUtilities contentTypeExtensionForImageData:data];
        
        return [[NSString alloc] initWithFormat:@"%@.%@",(NSString *) newUniqueIdString,extension];
    }else{
        // no filter, image is located on Library
        NSURL *url = [NSURL URLWithString:[dictionary objectForKey:@"url"]];
        return [NSString stringWithFormat:@"%@.%@",[AssetsLibraryUtilities getAssetsUrlId:url],[AssetsLibraryUtilities getAssetsUrlExtension:url]];
    }
}



+ (NSData *) getNSDataForDictionary:(NSDictionary *) dictionary
{
    BOOL isFiltered = [(NSNumber*) [dictionary objectForKey:@"filtered"] boolValue] ;
    
    if (isFiltered){
        // filtered        
    }else{
    // no filter, image is located on Library
        
    }
    
    return nil;
}



@end

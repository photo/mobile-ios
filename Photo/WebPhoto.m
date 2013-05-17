//
//  WebPhoto.m
//  Trovebox
//
//  Created by Patrick Santana on 19/03/13.
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

#import "WebPhoto.h"

@implementation WebPhoto

@synthesize date;
@synthesize identification;
@synthesize pageUrl;
@synthesize title;
@synthesize url;
@synthesize thumbWidth;
@synthesize thumbHeight;
@synthesize thumbUrl;
@synthesize mwphoto;

+ (WebPhoto *) photoWithServerInfo:(NSDictionary *) response
{
    WebPhoto *photo = [[WebPhoto alloc] init];
    
    if ([response objectForKey:@"id"] != nil){
        // Get title of the image
        NSString *title = [response objectForKey:@"title"];
        if ([title class] == [NSNull class])
            title = @"";
        
        // small url and url
        NSString *thumbUrl  = [NSString stringWithFormat:@"%@", [response objectForKey:[self getPathThumb]]];
        NSString *url       = [NSString stringWithFormat:@"%@", [response objectForKey:[self getPathUrl]]];
        NSString *pageUrl   = [NSString stringWithFormat:@"%@", [response objectForKey:@"url"]];
        
        // get width and height for the thumb
        NSArray* thumbPhotoDetails = [response objectForKey:[self getDetailsThumb]];
        float thumbWidth = [[thumbPhotoDetails objectAtIndex:1] floatValue];
        float thumbHeight = [[thumbPhotoDetails objectAtIndex:2] floatValue];
        
        photo.thumbUrl       = thumbUrl;
        photo.thumbHeight    = [NSNumber numberWithFloat:thumbHeight];
        photo.thumbWidth     = [NSNumber numberWithFloat:thumbWidth];
        photo.pageUrl        = pageUrl;
        photo.identification = [NSString stringWithFormat:@"%@",[response objectForKey:@"id"]];
        photo.url            = url;
        
        // get the date since 1970
        double d            = [[response objectForKey:@"dateTaken"] doubleValue];
        NSTimeInterval date =  d;
        photo.date          = [NSDate dateWithTimeIntervalSince1970:date];
        
        photo.mwphoto = [MWPhoto photoWithURL:[NSURL URLWithString:photo.url]];
    }
    
    // return result
    return photo;
}




- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToWidget:other];
}

- (BOOL)isEqualToWidget:(WebPhoto *)aWidget {
    if (self == aWidget)
        return YES;
    if (![(id)[self identification] isEqual:[aWidget identification]])
        return NO;
    if (![[self thumbUrl] isEqual:[aWidget thumbUrl]])
        return NO;
    if (![[self url] isEqual:[aWidget url]])
        return NO;
    return YES;
}

+ (NSString*) getDetailsThumb
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
        return @"photo300x300";
    }else{
        return @"photo200x200";
    }}

+ (NSString*) getPathThumb
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
        return @"path300x300";
    }else{
        return @"path200x200";
    }
}

+ (NSString*) getPathUrl
{
    if ([DisplayUtilities isIPad]){
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
            return @"path2024x1536";
        }else{
            return @"path1024x768";
        }
    }else{
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
            return @"path1136x640";
        }else{
            return @"path480x320";
        }
    }
}

@end

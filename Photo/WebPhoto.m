//
//  WebPhoto.m
//  Trovebox
//
//  Created by Patrick Santana on 19/03/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "WebPhoto.h"

@implementation WebPhoto

@synthesize date;
@synthesize height;
@synthesize identification;
@synthesize pageUrl;
@synthesize title;
@synthesize url;
@synthesize width;
@synthesize thumbWidth;
@synthesize thumbHeight;
@synthesize thumbUrl;

+ (WebPhoto *) photoWithServerInfo:(NSDictionary *) response
{
    WebPhoto *photo = [[WebPhoto alloc] init];
    
    if ([response objectForKey:@"id"] != nil){
        // Get title of the image
        NSString *title = [response objectForKey:@"title"];
        if ([title class] == [NSNull class])
            title = @"";
        
        // set all details
        float width = [[response objectForKey:@"width"] floatValue];
        float height = [[response objectForKey:@"height"] floatValue];
        
        // get width and height for the thumb
        NSArray* thumbPhotoDetails = [response objectForKey:@"photo200x200"];
        float thumbWidth = [[thumbPhotoDetails objectAtIndex:1] floatValue];
        float thumbHeight = [[thumbPhotoDetails objectAtIndex:2] floatValue];
        
        // calculate the real size of the image. It will keep the aspect ratio.
        float realWidth = 0;
        float realHeight = 0;
        
        if(width/height >= 1) {
            // portrait or square
            realWidth = 640;
            realHeight = height/width*640;
        } else {
            // landscape
            realHeight = 960;
            realWidth = width/height*960;
        }
        
        photo.title = title;
        photo.width          = [NSNumber numberWithFloat:realWidth];
        photo.height         = [NSNumber numberWithFloat:realHeight];
        photo.thumbUrl       = [NSString stringWithFormat:@"%@", [response objectForKey:@"path200x200"]];
        photo.thumbHeight    = [NSNumber numberWithFloat:thumbHeight];
        photo.thumbWidth     = [NSNumber numberWithFloat:thumbWidth];
        photo.url            = [NSString stringWithFormat:@"%@", [response objectForKey:@"path640x960"]];
        photo.pageUrl        = [NSString stringWithFormat:@"%@", [response objectForKey:@"url"]];
        photo.identification = [NSString stringWithFormat:@"%@",[response objectForKey:@"id"]];
        
        // get the date since 1970
        double d            = [[response objectForKey:@"dateTaken"] doubleValue];
        NSTimeInterval date =  d;
        photo.date          = [NSDate dateWithTimeIntervalSince1970:date];
    }
    
    // return result
    return photo;
}

@end

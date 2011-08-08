//
//  ImageManipulation.m
//  OpenPhoto
//
//  Created by Patrick Santana on 08/08/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "ImageManipulation.h"

@implementation ImageManipulation

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (UIImage*)imageWithImage:(UIImage*)image 
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

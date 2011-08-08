//
//  ImageManipulation.h
//  OpenPhoto
//
//  Created by Patrick Santana on 08/08/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageManipulation : NSObject


+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
@end

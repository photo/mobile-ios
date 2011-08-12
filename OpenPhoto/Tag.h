//
//  Tag.h
//  OpenPhoto
//
//  Created by Patrick Santana on 11/08/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Tag : NSObject{
    NSString *tagName;
    NSInteger quantity;
}

// constructor with tag name
- (id)initWithTagName:(NSString*) name Quantity:(NSInteger) qtd;

@property (nonatomic, copy) NSString *tagName;
@property (nonatomic) NSInteger quantity;

@end

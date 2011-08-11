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
}

// constructor with tag name
- (id)initWithTagName:(NSString*) name;

@property (nonatomic, copy) NSString *tagName;

@end

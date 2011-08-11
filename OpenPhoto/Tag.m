//
//  Tag.m
//  OpenPhoto
//
//  Created by Patrick Santana on 11/08/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "Tag.h"

@implementation Tag

@synthesize tagName;
- (id)initWithTagName:(NSString*) name{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.tagName=name;
    }
    
    return self;
}


///////////////// 
-(void) dealloc{
    [tagName release];
    [super dealloc];
}

@end

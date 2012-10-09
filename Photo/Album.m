//
//  Album.m
//  Photo
//
//  Created by Patrick Santana on 09/10/12.
//  Copyright (c) 2012 Photo Project. All rights reserved.
//

#import "Album.h"

@implementation Album

@synthesize name=_name,quantity=_quantity;

- (id)initWithAlbumName:(NSString*) name Quantity:(NSInteger) qtd{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.name=name;
        self.quantity = qtd;
    }
    
    return self;
}

@end

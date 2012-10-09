//
//  Album.h
//  Photo
//
//  Created by Patrick Santana on 09/10/12.
//  Copyright (c) 2012 Photo Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Album : NSObject

// constructor with tag name
- (id)initWithAlbumName:(NSString*) name Quantity:(NSInteger) qtd;

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger quantity;

@end

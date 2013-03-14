//
//  Gallery+Photo.h
//  Trovebox
//
//  Created by Patrick Santana on 14/03/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "Photo.h"

@interface Photo (Methods)

+ (Photo *) photoWithServerInfo:(NSDictionary *) response
                           inManagedObjectContext:(NSManagedObjectContext *) context;

+ (NSArray *) getPhotosInManagedObjectContext:(NSManagedObjectContext *)context;

+ (void) deletePhotosInManagedObjectContext:(NSManagedObjectContext *)context;

@end

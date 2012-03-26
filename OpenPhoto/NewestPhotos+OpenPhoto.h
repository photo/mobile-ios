//
//  NewestPhotos+OpenPhoto.h
//  OpenPhoto
//
//  Created by Patrick Santana on 22/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "NewestPhotos.h"

@interface NewestPhotos (OpenPhoto)


+ (NSArray *) getNewestPhotosInManagedObjectContext:(NSManagedObjectContext *)context;
+ (void) deleteAllNewestPhotosInManagedObjectContext:(NSManagedObjectContext *)context;

@end

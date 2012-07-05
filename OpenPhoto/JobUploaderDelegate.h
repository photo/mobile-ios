//
//  JobUploaderDelegate.h
//  OpenPhoto
//
//  Created by Patrick Santana on 05/07/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "ASIProgressDelegate.h"

@interface JobUploaderDelegate : NSObject <ASIProgressDelegate>

- (id) initWithPhoto:(TimelinePhotos*) photo size:(NSUInteger) bytes;


@end

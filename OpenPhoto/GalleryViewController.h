//
//  GalleryViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 11/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Three20/Three20.h>
#import "MockPhotoSource.h"
#import "extThree20JSON/JSON.h"


@class PhotoSet;

@interface GalleryViewController : TTThumbsViewController {
        NSMutableData *responseData;
}

@end

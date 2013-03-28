//
//  PhotoDetailViewController.h
//  Trovebox
//
//  Created by Patrick Santana on 27/03/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NetworkPhotoAlbumViewController.h"
#import "WebPhoto.h"

@interface PhotoDetailViewController : NetworkPhotoAlbumViewController <NIPhotoAlbumScrollViewDataSource, NIPhotoScrubberViewDataSource, NIOperationDelegate>

- (id)initWithPhotos:(NSArray*) photos position:(NSUInteger)index;

@end

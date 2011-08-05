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
#import "WebService.h"

@class PhotoSet;

@interface GalleryViewController : TTThumbsViewController <WebServiceDelegate>{
    WebService* service;
}
@property (nonatomic, retain) WebService* service;

@end

//
//  GalleryViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 11/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Three20/Three20.h>
#import "PhotoSource.h"
#import "WebService.h"
#import "OpenPhotoTTThumbsViewController.h"

@class PhotoSet;

@interface GalleryViewController : OpenPhotoTTThumbsViewController <WebServiceDelegate>{
    WebService* service;
    NSString *tagName;
}

@property (nonatomic, retain) WebService *service;
@property (nonatomic, copy) NSString *tagName;

// methods
- (id) initWithTagName:(NSString*) tag;

@end

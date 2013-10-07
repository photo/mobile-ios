//
//  MWPhoto.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWPhotoProtocol.h"

// This class models a photo/image and it's caption
// If you want to handle photos, caching, decompression
// yourself then you can simply ensure your custom data model
// conforms to MWPhotoProtocol
@interface MWPhoto : NSObject <MWPhoto>

// Properties
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) NSURL *photoURL;
@property (nonatomic, readonly) NSString *filePath  __attribute__((deprecated("Use photoURL"))); // Depreciated

// Properties from our side
@property (nonatomic, strong) NSDate   *date;
@property (nonatomic, strong) NSString *identification;
@property (nonatomic, strong) NSString *pageUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *thumbWidth;
@property (nonatomic, strong) NSNumber *thumbHeight;
@property (nonatomic, strong) NSString *thumbUrl;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSNumber *permission;

// Class
+ (MWPhoto *)photoWithImage:(UIImage *)image;
+ (MWPhoto *)photoWithFilePath:(NSString *)path  __attribute__((deprecated("Use photoWithURL: with a file URL"))); // Depreciated
+ (MWPhoto *)photoWithURL:(NSURL *)url;
+ (MWPhoto *) photoWithServerInfo:(NSDictionary *) response;

// Init
- (id)initWithImage:(UIImage *)image;
- (id)initWithURL:(NSURL *)url;
- (id)initWithFilePath:(NSString *)path  __attribute__((deprecated("Use initWithURL: with a file URL"))); // Depreciated

@end


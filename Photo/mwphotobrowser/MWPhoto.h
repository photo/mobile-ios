//
//  MWPhoto.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWPhotoProtocol.h"

// image cache
#import <SDWebImage/UIImageView+WebCache.h>

// This class models a photo/image and it's caption
// If you want to handle photos, caching, decompression
// yourself then you can simply ensure your custom data model
// conforms to MWPhotoProtocol
@interface MWPhoto : NSObject <MWPhoto>

// Properties
@property (nonatomic, retain) NSString *caption;

// Properties from our side
@property (nonatomic, retain) NSDate   *date;
@property (nonatomic, retain) NSString *identification;
@property (nonatomic, retain) NSString *pageUrl;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *thumbWidth;
@property (nonatomic, retain) NSNumber *thumbHeight;
@property (nonatomic, retain) NSString *thumbUrl;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSNumber * permission;

// Class
+ (MWPhoto *) photoWithImage:(UIImage *)image;
+ (MWPhoto *) photoWithFilePath:(NSString *)path;
+ (MWPhoto *) photoWithURL:(NSURL *)url;
+ (MWPhoto *) photoWithServerInfo:(NSDictionary *) response;

// Init
- (id)initWithImage:(UIImage *)image;
- (id)initWithFilePath:(NSString *)path;
- (id)initWithURL:(NSURL *)url;

@end


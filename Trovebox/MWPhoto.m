//
//  MWPhoto.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SDWebImageDecoder.h"
#import <AssetsLibrary/AssetsLibrary.h>

// Private
@interface MWPhoto () {

    BOOL _loadingInProgress;
        
}

// Properties
@property (nonatomic, strong) UIImage *underlyingImage; // holds the decompressed image

// Methods
- (void)decompressImageAndFinishLoading;
- (void)imageLoadingComplete;

@end

// MWPhoto
@implementation MWPhoto

// Properties
@synthesize underlyingImage = _underlyingImage;
@synthesize caption = _caption;
@synthesize date = _date;
@synthesize identification = _identification;
@synthesize pageUrl = _pageUrl;
@synthesize title = _title;
@synthesize thumbWidth = _thumbWidth;
@synthesize thumbHeight = _thumbHeight;
@synthesize thumbUrl = _thumbUrl;
@synthesize url = _url;
@synthesize permission = _permission;

#pragma mark Class Methods

+ (MWPhoto *)photoWithImage:(UIImage *)image {
	return [[MWPhoto alloc] initWithImage:image];
}

// Depricated
+ (MWPhoto *)photoWithFilePath:(NSString *)path {
    return [MWPhoto photoWithURL:[NSURL fileURLWithPath:path]];
}

+ (MWPhoto *)photoWithURL:(NSURL *)url {
	return [[MWPhoto alloc] initWithURL:url];
}

#pragma mark NSObject

- (id)initWithImage:(UIImage *)image {
	if ((self = [super init])) {
		_image = image;
	}
	return self;
}

// Depricated
- (id)initWithFilePath:(NSString *)path {
	if ((self = [super init])) {
		_photoURL = [NSURL fileURLWithPath:path];
	}
	return self;
}

- (id)initWithURL:(NSURL *)url {
	if ((self = [super init])) {
		_photoURL = [url copy];
	}
	return self;
}

#pragma mark MWPhoto Protocol Methods

- (UIImage *)underlyingImage {
    return _underlyingImage;
}

- (void)loadUnderlyingImageAndNotify {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    _loadingInProgress = YES;
    if (self.underlyingImage) {
        
        // Image already loaded
        [self imageLoadingComplete];
        
    } else {
        
        // Get underlying image
        if (_image) {
            
            // We have UIImage so decompress
            self.underlyingImage = _image;
            [self decompressImageAndFinishLoading];
            
        } else if (_photoURL) {
            
            // Check what type of url it is
            if ([[[_photoURL scheme] lowercaseString] isEqualToString:@"assets-library"]) {
                
                // Load from asset library async
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    @autoreleasepool {
                        @try {
                            ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
                            [assetslibrary assetForURL:_photoURL
                                           resultBlock:^(ALAsset *asset){
                                               ALAssetRepresentation *rep = [asset defaultRepresentation];
                                               CGImageRef iref = [rep fullScreenImage];
                                               if (iref) {
                                                   self.underlyingImage = [UIImage imageWithCGImage:iref];
                                               }
                                               [self performSelectorOnMainThread:@selector(decompressImageAndFinishLoading) withObject:nil waitUntilDone:NO];
                                           }
                                          failureBlock:^(NSError *error) {
                                              self.underlyingImage = nil;
                                              MWLog(@"Photo from asset library error: %@",error);
                                              [self performSelectorOnMainThread:@selector(decompressImageAndFinishLoading) withObject:nil waitUntilDone:NO];
                                          }];
                        } @catch (NSException *e) {
                            MWLog(@"Photo from asset library error: %@", e);
                            [self performSelectorOnMainThread:@selector(decompressImageAndFinishLoading) withObject:nil waitUntilDone:NO];
                        }
                    }
                });
                
            } else if ([_photoURL isFileReferenceURL]) {
                
                // Load from local file async
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    @autoreleasepool {
                        @try {
                            self.underlyingImage = [UIImage imageWithContentsOfFile:_photoURL.path];
                            if (!_underlyingImage) {
                                MWLog(@"Error loading photo from path: %@", _photoPath);
                            }
                        } @finally {
                            [self performSelectorOnMainThread:@selector(decompressImageAndFinishLoading) withObject:nil waitUntilDone:NO];
                        }
                    }
                });
                
            } else {
                
                // Load async from web (using SDWebImage)
                @try {
                    SDWebImageManager *manager = [SDWebImageManager sharedManager];
                    [manager downloadWithURL:_photoURL
                                     options:0
                                    progress:^(NSUInteger receivedSize, long long expectedSize) {
                                        float progress = receivedSize / (float)expectedSize;
                                        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                              [NSNumber numberWithFloat:progress], @"progress",
                                                              self, @"photo", nil];
                                        [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_PROGRESS_NOTIFICATION object:dict];
                                    }
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                       if (error) {
                                           MWLog(@"SDWebImage failed to download image: %@", error);
                                       }
                                       self.underlyingImage = image;
                                       [self decompressImageAndFinishLoading];
                                   }];
                } @catch (NSException *e) {
                    MWLog(@"Photo from web: %@", e);
                    [self decompressImageAndFinishLoading];
                }
                
            }
            
        } else {
            
            // Failed - no source
            self.underlyingImage = nil;
            [self imageLoadingComplete];
            
        }
    }
}

// Release if we can get it again from path or url
- (void)unloadUnderlyingImage {
    _loadingInProgress = NO;
	if (self.underlyingImage) {
		self.underlyingImage = nil;
	}
}

- (void)decompressImageAndFinishLoading {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    if (self.underlyingImage) {
        // Decode image async to avoid lagging when UIKit lazy loads
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.underlyingImage = [UIImage decodedImageWithImage:self.underlyingImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Finish on main thread
                [self imageLoadingComplete];
            });
        });
    } else {
        // Failed
        [self imageLoadingComplete];
    }
}

- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    _loadingInProgress = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                                        object:self];
}


#pragma mark - Internal code from Trovebox
+ (MWPhoto *) photoWithServerInfo:(NSDictionary *) response
{
    
    if ([response objectForKey:@"id"] != nil){
        // Get title of the image
        NSString *title = [response objectForKey:@"title"];
        if ([title class] == [NSNull class])
            title = @"";
        
        // small url and url
        NSString *thumbUrl  = [NSString stringWithFormat:@"%@", [response objectForKey:[self getPathThumb]]];
        NSString *url       = [NSString stringWithFormat:@"%@", [response objectForKey:[self getPathUrl]]];
        NSString *pageUrl   = [NSString stringWithFormat:@"%@", [response objectForKey:@"url"]];
        
        // get width and height for the thumb
        NSArray* thumbPhotoDetails = [response objectForKey:[self getDetailsThumb]];
        float thumbWidth = [[thumbPhotoDetails objectAtIndex:1] floatValue];
        float thumbHeight = [[thumbPhotoDetails objectAtIndex:2] floatValue];
        
        // get the date since 1970
        double d            = [[response objectForKey:@"dateTaken"] doubleValue];
        NSTimeInterval date =  d;
        
        // create object
        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:url]];
        photo.url            = [url copy];
        photo.thumbUrl       = [thumbUrl copy];
        photo.thumbHeight    = [NSNumber numberWithFloat:thumbHeight];
        photo.thumbWidth     = [NSNumber numberWithFloat:thumbWidth];
        photo.pageUrl        = [pageUrl copy];
        photo.identification = [NSString stringWithFormat:@"%@",[response objectForKey:@"id"]];
        photo.date           = [NSDate dateWithTimeIntervalSince1970:date];
        
        // permission
        if ([[response objectForKey:@"permission"] isEqualToString:@"1"])
            photo.permission = [NSNumber numberWithBool:YES];
        else
            photo.permission = [NSNumber numberWithBool:NO];
        
        // return result
        return photo;
    }
    
    // error
    return nil;
    
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToWidget:other];
}

- (BOOL)isEqualToWidget:(MWPhoto *)aWidget {
    if (self == aWidget)
        return YES;
    if (![(id)[self identification] isEqual:[aWidget identification]])
        return NO;
    if (![[self thumbUrl] isEqual:[aWidget thumbUrl]])
        return NO;
    if (![[self url] isEqual:[aWidget url]])
        return NO;
    return YES;
}

+ (NSString*) getDetailsThumb
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
        return @"photo300x300";
    }else{
        return @"photo200x200";
    }}

+ (NSString*) getPathThumb
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
        return @"path300x300";
    }else{
        return @"path200x200";
    }
}

+ (NSString*) getPathUrl
{
    if ([DisplayUtilities isIPad]){
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
            return @"path2024x1536";
        }else{
            return @"path1024x768";
        }
    }else{
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
            return @"path1136x640";
        }else{
            return @"path480x320";
        }
    }
}


@end

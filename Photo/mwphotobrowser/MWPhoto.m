//
//  MWPhoto.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"

// Private
@interface MWPhoto () {
    
    // Image Sources
    NSString *_photoPath;
    NSURL *_photoURL;
    
    // Image
    UIImage *_underlyingImage;
    
    // Other
    NSString *_caption;
    BOOL _loadingInProgress;
    
}

// Properties
@property (nonatomic, retain) UIImage *underlyingImage;

// Methods
- (void)imageDidFinishLoadingSoDecompress;
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

#pragma mark Class Methods

+ (MWPhoto *)photoWithImage:(UIImage *)image {
	return [[[MWPhoto alloc] initWithImage:image] autorelease];
}

+ (MWPhoto *)photoWithFilePath:(NSString *)path {
	return [[[MWPhoto alloc] initWithFilePath:path] autorelease];
}

+ (MWPhoto *)photoWithURL:(NSURL *)url {
	return [[[MWPhoto alloc] initWithURL:url] autorelease];
}

#pragma mark NSObject

- (id)initWithImage:(UIImage *)image {
	if ((self = [super init])) {
		self.underlyingImage = image;
	}
	return self;
}

- (id)initWithFilePath:(NSString *)path {
	if ((self = [super init])) {
		_photoPath = [path copy];
	}
	return self;
}

- (id)initWithURL:(NSURL *)url {
	if ((self = [super init])) {
		_photoURL = [url copy];
	}
	return self;
}

- (void)dealloc {
    [_caption release];
	[_photoPath release];
	[_photoURL release];
	[_underlyingImage release];
    [_caption release];
    [_date release];
    [_identification release];
    [_pageUrl release];
    [_title release];
    [_thumbWidth release];
    [_thumbHeight release];
    [_thumbUrl release];
    [_url release];
	[super dealloc];
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
        if (_photoPath) {
            // Load async from file
            [self performSelectorInBackground:@selector(loadImageFromFileAsync) withObject:nil];
        } else if (_photoURL) {
            // Load async from web (using SDWebImage)
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadWithURL:_photoURL
                             options:0
                            progress:nil
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
             {
                 if (image)
                 {
                     // do something with image
                     self.underlyingImage = image;
                     [self imageLoadingComplete];
                 }
             }];
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
	if (self.underlyingImage && (_photoPath || _photoURL)) {
		self.underlyingImage = nil;
	}
}

#pragma mark - Async Loading

// Called in background
// Load image in background from local file
- (void)loadImageFromFileAsync {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfFile:_photoPath options:NSDataReadingUncached error:&error];
        if (!error) {
            self.underlyingImage = [[[UIImage alloc] initWithData:data] autorelease];
        } else {
            self.underlyingImage = nil;
            MWLog(@"Photo from file error: %@", error);
        }
    } @catch (NSException *exception) {
    } @finally {
        [self performSelectorOnMainThread:@selector(imageDidFinishLoadingSoDecompress) withObject:nil waitUntilDone:NO];
        [pool drain];
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

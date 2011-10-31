#import "PhotoSource.h"

@implementation PhotoSource

@synthesize title = _title;
@synthesize numberOfPhotos = _numberOfPhotos;

int number = 0;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithTitle:(NSString*)title photos:(NSArray*)photos size:(int) size{
    if (self = [super init]) {
        _title = [title copy];
        _photos =  [photos mutableCopy];
        _numberOfPhotos = size;
        
        for (int i = 0; i < _photos.count; ++i) {
            id<TTPhoto> photo = [_photos objectAtIndex:i];
            if ((NSNull*)photo != [NSNull null]) {
                photo.photoSource = self;
                photo.index = i;
            }
        }
    }
    return self;
}

- (id)init {
    return [self initWithTitle:nil photos:nil size:0];
}

- (void)dealloc {
    TT_RELEASE_SAFELY(_photos);
    TT_RELEASE_SAFELY(_title);
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel
- (BOOL)isLoaded {
    return !!_photos;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    if (cachePolicy & TTURLRequestCachePolicyNetwork) {
        [_delegates perform:@selector(modelDidStartLoad:) withObject:self];
        number = number+25;
        NSLog(@"loading");
        [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhotoSource

- (NSInteger)numberOfPhotos {
    return _numberOfPhotos;
}

- (NSInteger)maxPhotoIndex {
    return number;
}

- (id<TTPhoto>)photoAtIndex:(NSInteger)photoIndex {
    if (photoIndex < _photos.count) {
        id photo = [_photos objectAtIndex:photoIndex];
        if (photo == [NSNull null]) {
            return nil;
        } else {
            return photo;
        }
    } else {
        return nil;
    }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation Photo

@synthesize photoSource = _photoSource, size = _size, index = _index, caption = _caption;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithURL:(NSString*)URL smallURL:(NSString*)smallURL size:(CGSize)size {
    return [self initWithURL:URL smallURL:smallURL size:size caption:nil];
}

- (id)initWithURL:(NSString*)URL smallURL:(NSString*)smallURL size:(CGSize)size
          caption:(NSString*)caption {
    if (self = [super init]) {
        _photoSource = nil;
        _URL = [URL copy];
        _smallURL = [smallURL copy];
        _thumbURL = [smallURL copy];
        _size = size;
        _caption = [caption copy];
        _index = NSIntegerMax;
    }
    return self;
}

- (void)dealloc {
    TT_RELEASE_SAFELY(_URL);
    TT_RELEASE_SAFELY(_smallURL);
    TT_RELEASE_SAFELY(_thumbURL);
    TT_RELEASE_SAFELY(_caption);
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhoto

- (NSString*)URLForVersion:(TTPhotoVersion)version {
    if (version == TTPhotoVersionLarge) {
        return _URL;
    } else if (version == TTPhotoVersionMedium) {
        return _URL;
    } else if (version == TTPhotoVersionSmall) {
        return _smallURL;
    } else if (version == TTPhotoVersionThumbnail) {
        return _thumbURL;
    } else {
        return nil;
    }
}

@end

#import <Three20/Three20.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface MockPhotoSource : TTURLRequestModel <TTPhotoSource> {
    NSString* _title;
    NSMutableArray* _photos;
    NSArray* _tempPhotos;
    NSTimer* _fakeLoadTimer;
}

- (id)initWithTitle:(NSString*)title
            photos:(NSArray*)photos photos2:(NSArray*)photos2;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface Photo : NSObject <TTPhoto> {
    id<TTPhotoSource> _photoSource;
    NSString* _thumbURL;
    NSString* _smallURL;
    NSString* _URL;
    CGSize _size;
    NSInteger _index;
    NSString* _caption;
}

- (id)initWithURL:(NSString*)URL smallURL:(NSString*)smallURL size:(CGSize)size;

- (id)initWithURL:(NSString*)URL smallURL:(NSString*)smallURL size:(CGSize)size
          caption:(NSString*)caption;

@end

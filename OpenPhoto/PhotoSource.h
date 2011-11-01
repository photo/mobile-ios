#import <Three20/Three20.h>
#import "Three20Core/NSArrayAdditions.h"
#import "WebService.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface PhotoSource : TTURLRequestModel <TTPhotoSource> {
    NSString* _title;
    NSMutableArray* photos;
    int numberOfPhotos;
    int currentPage;
    NSString* tagName;
    WebService* service;
}

@property (nonatomic, copy) NSString* tagName;
@property (nonatomic, retain) WebService *service;
@property (nonatomic, retain) NSMutableArray* photos;
@property (nonatomic) int currentPage;

- (id)initWithTitle:(NSString*)title photos:(NSArray*)listPhotos size:(int) size tag:(NSString*) tag;

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

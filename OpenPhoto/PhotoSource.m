#import "PhotoSource.h"

@implementation PhotoSource

@synthesize title = _title;
@synthesize tagName = _tagName;
@synthesize numberOfPhotos = _numberOfPhotos;
@synthesize currentPage = _currentPage;
@synthesize service;
@synthesize photos;

int actualMaxPhotoIndex = 0;
BOOL isLoading = NO;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithTitle:(NSString*)title photos:(NSArray*)listPhotos size:(int) size tag:(NSString*) tag{
    if (self = [super init]) {
        _title = [title copy];
        self.photos =  [listPhotos mutableCopy];
        _numberOfPhotos = size;
        _tagName = tag;
        
        // the first page
        _currentPage = 1;
        
        // create service and the delegate
        self.service = [[WebService alloc]init];
        [service setDelegate:self];
        
        for (int i = 0; i < self.photos.count; ++i) {
            id<TTPhoto> photo = [self.photos objectAtIndex:i];
            if ((NSNull*)photo != [NSNull null]) {
                photo.photoSource = self;
                photo.index = i;
            }
        }
    }
    return self;
}

- (id)init {
    return [self initWithTitle:nil photos:nil size:0 tag:nil];
}

- (void)dealloc {
    TT_RELEASE_SAFELY(_title);
    [self.service release];
    [self.photos release];
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel
- (BOOL)isLoaded {
    return !!self.photos;
}

- (BOOL) isLoading{
    return isLoading;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    if (cachePolicy & TTURLRequestCachePolicyNetwork) {
        _currentPage++;
        actualMaxPhotoIndex = actualMaxPhotoIndex+25;
        
        if (self.photos != nil && _title != nil && _currentPage > 1){
            isLoading = YES;
            [_delegates perform:@selector(modelDidStartLoad:) withObject:self];
            
            NSArray *keys;           
            NSArray *objects;
            NSNumber* number=[NSNumber numberWithInt:_currentPage];
            
            if (_tagName != nil){
                keys = [NSArray arrayWithObjects:@"tag", @"page",nil];
                objects= [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@", _tagName], number, nil];  
            }else{
                keys = [NSArray arrayWithObjects:@"page",nil];
                objects= [NSArray arrayWithObjects:number, nil];
            }
            NSDictionary *values = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
            
            // to send the request we add a thread.
            [NSThread detachNewThreadSelector:@selector(loadNewPhotosOnDetachTread:) 
                                     toTarget:self 
                                   withObject:values];
        }
    }
}
-(void) loadNewPhotosOnDetachTread:(NSDictionary*) values
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if ([values objectForKey:@"tag"] == nil){
        [service loadGallery:25 onPage:[[values objectForKey:@"page"] intValue] ];
    }else{
        [service loadGallery:25 withTag:[values objectForKey:@"tag"]  onPage:[[values objectForKey:@"page"] intValue] ];
    } 
    
    [pool release];
}


- (void)cancel {
    isLoading = NO;
}

// delegate to add more pictures 
-(void) receivedResponse:(NSDictionary *)response{
    // check if message is valid
    if (![WebService isMessageValid:response]){
        NSString* message = [WebService getResponseMessage:response];
        NSLog(@"Invalid response = %@",message);
        
        // show alert to user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Response Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    NSArray *responsePhotos = [response objectForKey:@"result"] ;
    NSMutableArray *localPhotos = [[NSMutableArray alloc] init];
    int photoId=self.photos.count;
    
    // result can be null
    if ([responsePhotos class] != [NSNull class]) {
        
        // Loop through each entry in the dictionary and create an array of MockPhoto
        for (NSDictionary *photo in responsePhotos){
            // index photo
            photoId++;
            
            // Get title/description of the image
            NSString *localTitle = [photo objectForKey:@"title"];
            
#ifdef DEVELOPMENT_ENABLED      
            NSString *description = [photo objectForKey:@"description"];            
            NSString *photoURLString = [NSString stringWithFormat:@"http://%@%@", [photo objectForKey:@"host"], [photo objectForKey:@"path200x200"]];
            NSLog(@"Photo url [%@] with tile [%@] and description [%@]", photoURLString, (localTitle.length > 0 ? localTitle : @"Untitled"),(description.length > 0 ? description : @"Untitled"));
#endif            
            
            float width = [[photo objectForKey:@"width"] floatValue];
            float height = [[photo objectForKey:@"height"] floatValue];
            
            // calculate the real size of the image. It will keep the aspect ratio.
            float realWidth = 0;
            float realHeight = 0;
            
            if(width/height >= 1) { 
                // portrait or square
                realWidth = 640;
                realHeight = height/width*640;
            } else { 
                // landscape
                realHeight = 960;
                realWidth = width/height*960;
            }
            Photo* obj = [[[Photo alloc]
                           initWithURL:[NSString stringWithFormat:@"%@", [photo objectForKey:@"path640x960"]]
                           smallURL:[NSString stringWithFormat:@"%@",[photo objectForKey:@"path200x200"]] 
                           size:CGSizeMake(realWidth, realHeight) caption:localTitle] autorelease];
            obj.index=photoId;
            obj.photoSource = self;
            // add to array
            [localPhotos addObject:obj];
            
        } 
    }
    [self.photos addObjectsFromArray:localPhotos];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
#ifdef TEST_FLIGHT_ENABLED
    [TestFlight passCheckpoint:@"Gallery Loaded"];
#endif
    
    // Finishes
    isLoading = NO;
    [localPhotos release];
    [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhotoSource

- (NSInteger)numberOfPhotos {
    return _numberOfPhotos;
}

- (NSInteger)maxPhotoIndex {
    return actualMaxPhotoIndex-1;
}

- (id<TTPhoto>)photoAtIndex:(NSInteger)photoIndex {
    if (photoIndex < self.photos.count) {
        id photo = [self.photos objectAtIndex:photoIndex];
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

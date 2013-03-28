//
//  PhotoDetailViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 27/03/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "PhotoDetailViewController.h"
@interface PhotoDetailViewController()
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic) NSUInteger index;
@end

@implementation PhotoDetailViewController

@synthesize photos=_photos, index=_index;

- (id)initWithPhotos:(NSArray*) photos position:(NSUInteger)index
{
  if ((self = [self initWithNibName:nil bundle:nil])) {
        self.photos = photos;
      self.index = index;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadThumbnails {
    for (NSInteger ix = 0; ix < [self.photos count]; ++ix) {
        WebPhoto* photo = [self.photos objectAtIndex:ix];
        
        NSString* photoIndexKey = [self cacheKeyForPhotoIndex:ix];
        
        // Don't load the thumbnail if it's already in memory.
        if (![self.thumbnailImageCache containsObjectWithName:photoIndexKey]) {
            NSString* source = photo.thumbUrl;
            [self requestImageFromSource: source
                               photoSize: NIPhotoScrollViewPhotoSizeThumbnail
                              photoIndex: ix];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
    [super loadView];
    
    self.photoAlbumView.dataSource = self;
    self.photoScrubberView.dataSource = self;
    
    // Dribbble is for mockups and designs, so we don't want to allow the photos to be zoomed
    // in and become blurry.
    self.photoAlbumView.zoomingAboveOriginalSizeIsEnabled = YES;
    
    // This title will be displayed until we get the results back for the album information.
    self.title = NSLocalizedString(@"Loading...", @"Navigation bar title - Loading a photo album");
    
    [self loadThumbnails];
    
    [self.photoAlbumView reloadData];
    self.photoScrubberView.selectedPhotoIndex = self.index;
    self.photoAlbumView.
    [self.photoScrubberView reloadData];
    
    
    [self refreshChromeState];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.photos = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIPhotoScrubberViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPhotosInScrubberView:(NIPhotoScrubberView *)photoScrubberView {
    return [self.photos count];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage *)photoScrubberView: (NIPhotoScrubberView *)photoScrubberView
              thumbnailAtIndex: (NSInteger)thumbnailIndex {
    NSString* photoIndexKey = [self cacheKeyForPhotoIndex:thumbnailIndex];
    
    UIImage* image = [self.thumbnailImageCache objectWithName:photoIndexKey];
    if (nil == image) {
        WebPhoto* photo = [self.photos objectAtIndex:thumbnailIndex];
        
        NSString* thumbnailSource = photo.thumbUrl;
        
        [self requestImageFromSource: thumbnailSource
                           photoSize: NIPhotoScrollViewPhotoSizeThumbnail
                          photoIndex: thumbnailIndex];
    }
    
    return image;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIPhotoAlbumScrollViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPagesInPagingScrollView:(NIPhotoAlbumScrollView *)photoScrollView {
    return [self.photos count];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage *)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
                     photoAtIndex: (NSInteger)photoIndex
                        photoSize: (NIPhotoScrollViewPhotoSize *)photoSize
                        isLoading: (BOOL *)isLoading
          originalPhotoDimensions: (CGSize *)originalPhotoDimensions {
    UIImage* image = nil;
    
    NSString* photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];
    
    WebPhoto* photo = [self.photos objectAtIndex:photoIndex];
    
    // Let the photo album view know how large the photo will be once it's fully loaded.
//    *originalPhotoDimensions = [[photo objectForKey:@"dimensions"] CGSizeValue];
    
    image = [self.highQualityImageCache objectWithName:photoIndexKey];
    if (nil != image) {
        *photoSize = NIPhotoScrollViewPhotoSizeOriginal;
        
    } else {
        NSString* source = photo.url;
        [self requestImageFromSource: source
                           photoSize: NIPhotoScrollViewPhotoSizeOriginal
                          photoIndex: photoIndex];
        
        *isLoading = YES;
        
        // Try to return the thumbnail image if we can.
        image = [self.thumbnailImageCache objectWithName:photoIndexKey];
        if (nil != image) {
            *photoSize = NIPhotoScrollViewPhotoSizeThumbnail;
            
        } else {
            // Load the thumbnail as well.
            NSString* thumbnailSource = photo.thumbUrl;
            [self requestImageFromSource: thumbnailSource
                               photoSize: NIPhotoScrollViewPhotoSizeThumbnail
                              photoIndex: photoIndex];
            
        }
    }
    
    return image;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
     stopLoadingPhotoAtIndex: (NSInteger)photoIndex {
    // TODO: Figure out how to implement this with AFNetworking.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<NIPagingScrollViewPage>)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex {
    return [self.photoAlbumView pagingScrollView:pagingScrollView pageViewForIndex:pageIndex];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault
                                                animated: animated];
    
    UINavigationBar* navBar = self.navigationController.navigationBar;
    navBar.barStyle = UIBarStyleDefault;
    navBar.translucent = NO;
}

@end

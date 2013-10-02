//
//  AssetCell.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetCell.h"
#import "ELCAsset.h"

@interface ELCAssetCell ()

@property (nonatomic, strong) NSArray *rowAssets;
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) NSMutableArray *overlayViewArray;

@end

@implementation ELCAssetCell

@synthesize rowAssets = _rowAssets;

- (id)initWithAssets:(NSArray *)assets reuseIdentifier:(NSString *)identifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	if(self) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
        [self addGestureRecognizer:tapRecognizer];
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.imageViewArray = mutableArray;
        
        NSMutableArray *overlayArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.overlayViewArray = overlayArray;
        
        [self setAssets:assets];
	}
	return self;
}

- (void)setAssets:(NSArray *)assets
{
    self.rowAssets = assets;
	for (UIImageView *view in _imageViewArray) {
        [view removeFromSuperview];
	}
    for (UIImageView *view in _overlayViewArray) {
        [view removeFromSuperview];
	}
    //set up a pointer here so we don't keep calling [UIImage imageNamed:] if creating overlays
    UIImage *overlayImage = nil;
    UIImage *overlayUploaded = nil;
    
    for (int i = 0; i < [_rowAssets count]; ++i) {
        
        ELCAsset *asset = [_rowAssets objectAtIndex:i];
        
        if (i < [_imageViewArray count]) {
            UIImageView *imageView = [_imageViewArray objectAtIndex:i];
            imageView.image = [UIImage imageWithCGImage:asset.asset.thumbnail];
            
            
            // check if the user already uploaded this image
            if ( asset.uploaded){
                if (overlayUploaded == nil)
                    overlayUploaded = [UIImage imageNamed:@"sync-already-uploaded.png"];
                UIImageView *overlayUploadedView = [[UIImageView alloc] initWithImage:overlayUploaded];
                overlayUploadedView.frame =  CGRectMake(0, 0, 75, 75);
                [imageView addSubview:overlayUploadedView];
            }
             
            
        } else {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:asset.asset.thumbnail]];
            
            // check if the user already uploaded this image
            if ( asset.uploaded){
                if (overlayUploaded == nil)
                    overlayUploaded = [UIImage imageNamed:@"sync-already-uploaded.png"];
                UIImageView *overlayUploadedView = [[UIImageView alloc] initWithImage:overlayUploaded];
                overlayUploadedView.frame =  CGRectMake(0, 0, 75, 75);
                [imageView addSubview:overlayUploadedView];
            }
            
            [_imageViewArray addObject:imageView];
        }
        
        if (i < [_overlayViewArray count]) {
            UIImageView *overlayView = [_overlayViewArray objectAtIndex:i];
            overlayView.hidden = asset.selected ? NO : YES;
        } else {
            if (overlayImage == nil) {
                overlayImage = [UIImage imageNamed:@"sync-overlay.png"];
            }
            UIImageView *overlayView = [[UIImageView alloc] initWithImage:overlayImage];
            [_overlayViewArray addObject:overlayView];
            overlayView.hidden = asset.selected ? NO : YES;
        }
    }
}

- (void)cellTapped:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint point = [tapRecognizer locationInView:self];
    CGFloat totalWidth = self.rowAssets.count * 75 + (self.rowAssets.count - 1) * 4;
    CGFloat startX = (self.bounds.size.width - totalWidth) / 2;
    
	CGRect frame = CGRectMake(startX, 2, 75, 75);
	
	for (int i = 0; i < [_rowAssets count]; ++i) {
        if (CGRectContainsPoint(frame, point)) {
            ELCAsset *asset = [_rowAssets objectAtIndex:i];
            asset.selected = !asset.selected;
            UIImageView *overlayView = [_overlayViewArray objectAtIndex:i];
            overlayView.hidden = !asset.selected;
            
            // reach max
            if([(SyncViewController*) asset.parent totalSelectedAssets] >= 50) {
                PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Maximum reached",@"Sync") duration:5000];
                [alert showAlert];
                
                asset.selected = NO;
                overlayView.hidden = TRUE;
                
                [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"UI Action"
                                                                  withAction:@"buttonPress"
                                                                   withLabel:@"Sync - maximum reached"
                                                                   withValue:nil];
            }
            
            // check limits
            if ([SharedAppDelegate isHosted] && [SharedAppDelegate isFreeUser]){
                
                if ([SharedAppDelegate limitFreeUser] == 0 ||
                    [(SyncViewController*) asset.parent totalSelectedAssets] > [SharedAppDelegate limitFreeUser]){
                    // limit reached,
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Limit reached", nil)
                                                                    message: [NSString stringWithFormat:NSLocalizedString(@"You've reached your monthly limit of %d photos. Upgrade today for an unlimited Pro account.",@"Message when limit is reached"), [SharedAppDelegate limitAllowed]]
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                                          otherButtonTitles:NSLocalizedString(@"Upgrade",nil),nil];
                    [alert show];
                    asset.selected = NO;
                    overlayView.hidden = TRUE;
                }
            }
            
            
            break;
        }
        frame.origin.x = frame.origin.x + frame.size.width + 4;
    }
}

- (void)layoutSubviews
{
    CGFloat totalWidth = self.rowAssets.count * 75 + (self.rowAssets.count - 1) * 4;
    CGFloat startX = (self.bounds.size.width - totalWidth) / 2;
    
	CGRect frame = CGRectMake(startX, 2, 75, 75);
	
	for (int i = 0; i < [_rowAssets count]; ++i) {
		UIImageView *imageView = [_imageViewArray objectAtIndex:i];
		[imageView setFrame:frame];
		[self addSubview:imageView];
        
        UIImageView *overlayView = [_overlayViewArray objectAtIndex:i];
        [overlayView setFrame:frame];
        [self addSubview:overlayView];
		
		frame.origin.x = frame.origin.x + frame.size.width + 4;
	}
}

@end

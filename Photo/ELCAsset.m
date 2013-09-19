//
//  Asset.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAsset.h"


@interface ELCAsset(){
    BOOL uploaded;
    NSString* _type;
    NSString* _duration;
}

@end

@implementation ELCAsset

@synthesize parent=_parent;
@synthesize asset=_asset;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

-(id)initWithAsset:(ALAsset*) alasset alreadyUploaded:(BOOL) isUploaded type:(NSString*) type duration:(NSString*) time{
	
	if (self = [super initWithFrame:CGRectMake(0, 0, 0, 0)]) {
		
		self.asset = alasset;
		uploaded = isUploaded;
        _type = type;
        
		CGRect viewFrames = CGRectMake(0, 0, 75, 75);
		
		UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:viewFrames];
		[assetImageView setContentMode:UIViewContentModeScaleToFill];
		[assetImageView setImage:[UIImage imageWithCGImage:[self.asset thumbnail]]];
        [self addSubview:assetImageView];
        
        if ([_type isEqualToString:ALAssetTypeVideo]) {
            // asset is a video
            _duration = time;
         
            CGRect viewFramesVideo = CGRectMake(0, 60, 75, 15);
            UIView *overlayVideo= [[UIImageView alloc] initWithFrame:viewFramesVideo];
            overlayVideo.backgroundColor = [UIColor blackColor];
            overlayVideo.opaque= YES;
            overlayVideo.alpha = 0.5;
            [self addSubview:overlayVideo];
            
            UIFont *font = [UIFont systemFontOfSize:10];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 75, 15)];
            label.font = font;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            
            int minutes = floor([_duration intValue]/60);
            int seconds = round([_duration intValue] - minutes * 60);
            
            if (seconds <10){
            label.text = [NSString stringWithFormat:@"%d:0%d  ",minutes,seconds];
            }else{
                label.text = [NSString stringWithFormat:@"%d:%d  ",minutes,seconds];
            }
            label.textAlignment = NSTextAlignmentRight;
            label.shadowColor = [UIColor blackColor];
            label.shadowOffset = CGSizeMake(0, 1);
            [self addSubview:label];
            
            UIImageView *iconMovie = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 65)];
            iconMovie.image=[UIImage imageNamed:@"video-placeholder@2x.png"];
            iconMovie.contentMode = UIViewContentModeScaleAspectFit;
            [self addSubview:iconMovie];
        }
        
        
        overlayAlreadyUploadedView= [[UIImageView alloc] initWithFrame:viewFrames];
        if (isUploaded){
            // show  image for already uploaded
            [overlayAlreadyUploadedView setImage:[UIImage imageNamed:@"sync-already-uploaded.png"]];
            [overlayAlreadyUploadedView setHidden:NO];;
            [self addSubview:overlayAlreadyUploadedView];
        }
        
        overlayView = [[UIImageView alloc] initWithFrame:viewFrames];
        [overlayView setImage:[UIImage imageNamed:@"sync-overlay.png"]];
        [overlayView setHidden:YES];
        [self addSubview:overlayView];
    }
    
	return self;
}

-(void)toggleSelection {
    
	overlayView.hidden = !overlayView.hidden;
    overlayAlreadyUploadedView.hidden= !overlayAlreadyUploadedView.hidden;
    
    if([(SyncViewController*)self.parent totalSelectedAssets] >= 50) {
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Maximum reached",@"Sync") duration:5000];
        [alert showAlert];
        
        overlayView.hidden = TRUE;

        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"UI Action"
                                                          withAction:@"buttonPress"
                                                           withLabel:@"Sync - maximum reached"
                                                           withValue:nil];
    }
    
    // check limits
    if ([SharedAppDelegate isHosted] && [SharedAppDelegate isFreeUser]){
        
        if ([SharedAppDelegate limitFreeUser] == 0 ||
            [(SyncViewController*)self.parent totalSelectedAssets] > [SharedAppDelegate limitFreeUser]){
            // limit reached,
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Limit reached", nil)
                                                            message: [NSString stringWithFormat:NSLocalizedString(@"You've reached your monthly limit of %d photos. Upgrade today for an unlimited Pro account.",@"Message when limit is reached"), [SharedAppDelegate limitAllowed]]
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                                  otherButtonTitles:NSLocalizedString(@"Upgrade",nil),nil];
            [alert show];
            overlayView.hidden = TRUE;
        }
    }
}

-(BOOL)selected {
	return !overlayView.hidden;
}


-(void)setSelected:(BOOL)_selected {
	[overlayView setHidden:!_selected];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1){
        [(MenuViewController*) SharedAppDelegate.menuController displayProfileScreen];
    }
}

@end


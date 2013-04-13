//
//  Asset.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAsset.h"


@interface ELCAsset(){
    BOOL uploaded;
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

-(id)initWithAsset:(ALAsset*) alasset alreadyUploaded:(BOOL) isUploaded{
	
	if (self = [super initWithFrame:CGRectMake(0, 0, 0, 0)]) {
		
		self.asset = alasset;
		uploaded = isUploaded;
        
		CGRect viewFrames = CGRectMake(0, 0, 75, 75);
		
		UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:viewFrames];
		[assetImageView setContentMode:UIViewContentModeScaleToFill];
		[assetImageView setImage:[UIImage imageWithCGImage:[self.asset thumbnail]]];
        [self addSubview:assetImageView];
        
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
    
    if([(SyncViewController*)self.parent totalSelectedAssets] >= 90) {
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Maximum reached",@"Sync") duration:5000];
        [alert showAlert];
        
        
        overlayView.hidden = TRUE;
    }
    
    // check limits
    if ([SharedAppDelegate isFreeUser]){
        
        if ([SharedAppDelegate limitFreeUser] == 0 ||
            [(SyncViewController*)self.parent totalSelectedAssets] > [SharedAppDelegate limitFreeUser]){
            // limit reached,
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Limit reached", @"Upload - text in the upload form for limits")
                                                            message: NSLocalizedString(([NSString stringWithFormat:@"You've reached your monthly limit of %d photos. Upgrade today for an unlimited Pro account.", [SharedAppDelegate limitAllowed]]), @"Message when limit is reached")
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


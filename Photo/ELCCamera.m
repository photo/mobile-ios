//
//  ELCCamera.m
//  Photo
//
//  Created by Patrick Santana on 25/10/12.
//  Copyright (c) 2012 Photo Project. All rights reserved.
//

#import "ELCCamera.h"

@implementation ELCCamera

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    	CGRect viewFrames = CGRectMake(0, 0, 75, 75);
		
		UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:viewFrames];
		[assetImageView setContentMode:UIViewContentModeScaleToFill];
		[assetImageView setImage:[UIImage imageNamed:@"camera.jpg"]];
        [self addSubview:assetImageView];
    }
    return self;
}


-(void)toggleSelection {
    // open camera
    [(SyncViewController*)self.parent handleCamera];
}

@end

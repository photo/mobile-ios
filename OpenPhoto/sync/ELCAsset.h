//
//  Asset.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface ELCAsset : UIView {
	ALAsset *asset;
	UIImageView *overlayView;
	UIImageView *overlayAlreadyUploadedView;
	id parent;
}

@property (nonatomic, retain) ALAsset *asset;
@property (nonatomic, assign) id parent;


-(id)initWithAsset:(ALAsset*)_asset alreadyUploaded:(BOOL) uploaded;
-(BOOL) selected;

@end
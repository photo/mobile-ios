//
//  Asset.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SyncViewController.h"


@interface ELCAsset : UIView <UIAlertViewDelegate>{
	ALAsset *asset;
	UIImageView *overlayView;
	UIImageView *overlayAlreadyUploadedView;
	id parent;
}

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, weak) id parent;


-(id)initWithAsset:(ALAsset*)_asset alreadyUploaded:(BOOL) uploaded type:(NSString*) type duration:(NSString*) time;
-(BOOL) selected;

@end
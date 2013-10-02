//
//  Asset.h
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class ELCAsset;

@protocol ELCAssetDelegate <NSObject>

@optional
- (void)assetSelected:(ELCAsset *)asset;

@end

@interface ELCAsset : UIView <UIAlertViewDelegate>


@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, weak) id<ELCAssetDelegate> parent;
@property (nonatomic) BOOL selected;
@property (nonatomic) BOOL uploaded;

- (id)initWithAsset:(ALAsset*)_asset alreadyUploaded:(BOOL) uploaded type:(NSString*) type duration:(NSString*) time;

@end
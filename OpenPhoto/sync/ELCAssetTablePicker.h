//
//  AssetTablePicker.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetsLibraryUtilities.h"
#import "MBProgressHUD.h"
#import "SyncPhotos+OpenPhoto.h"

@interface ELCAssetTablePicker : UITableViewController
{
	ALAssetsGroup *assetGroup;
	
	NSMutableArray *elcAssets;
	int selectedAssets;
	
	id parent;
	
	NSOperationQueue *queue;
    ALAssetsLibrary *library;
    
    NSMutableArray *imagesAlreadyUploaded;
    
    BOOL loaded;
}

@property (nonatomic, assign) id parent;
@property (nonatomic, retain) ALAssetsGroup *assetGroup;
@property (nonatomic, retain) NSMutableArray *elcAssets;
@property (nonatomic, retain) NSMutableArray *imagesAlreadyUploaded;

-(int)totalSelectedAssets;
-(void)preparePhotos;

-(void)doneAction:(id)sender;

@end
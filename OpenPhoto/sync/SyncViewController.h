//
//  SyncViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 18/06/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetsLibraryUtilities.h"
#import "MBProgressHUD.h"
#import "SyncPhotos+OpenPhoto.h"
#import "ELCAsset.h"
#import "ELCAlbumPickerController.h" 
#import "ELCAssetCell.h"

@interface SyncViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
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
@property (retain, nonatomic) IBOutlet UITableView *tableView;

-(int)totalSelectedAssets;
-(void)preparePhotos;

-(void)doneAction:(id)sender;

@end
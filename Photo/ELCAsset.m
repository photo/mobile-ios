//
//  Asset.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAsset.h"
#import "ELCAssetTablePicker.h"


@interface ELCAsset(){
    NSString* _type;
    NSString* _duration;
    
	UIImageView *overlayAlreadyUploadedView;
}

@end

@implementation ELCAsset

@synthesize asset = _asset;
@synthesize parent = _parent;
@synthesize selected = _selected;
@synthesize uploaded= _uploaded;


-(id)initWithAsset:(ALAsset*) alasset alreadyUploaded:(BOOL) isUploaded type:(NSString*) type duration:(NSString*) time{
    
	self = [super init];
	if (self) {
        self.asset = alasset;
        _selected = NO;
        _uploaded = isUploaded;
        _type = type;
    }
    
	return self;
    
}


- (void)toggleSelection
{
    self.selected = !self.selected;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (selected) {
        if (_parent != nil && [_parent respondsToSelector:@selector(assetSelected:)]) {
            [_parent assetSelected:self];
        }
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1){
        [(MenuViewController*) SharedAppDelegate.menuController displayProfileScreen];
    }
}

@end


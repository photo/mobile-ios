//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by ELC on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"
#import "ELCAsset.h"
#import "ELCAssetCell.h"

@implementation ELCImagePickerController

@synthesize delegate = _myDelegate;

- (void)cancelImagePicker
{
	if([_myDelegate respondsToSelector:@selector(elcImagePickerControllerDidCancel:)]) {
		[_myDelegate performSelector:@selector(elcImagePickerControllerDidCancel:) withObject:self];
	}
}

- (void)selectedAssets:(NSArray *)assets
{
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	
    /*
	for(ALAsset *asset in assets) {
        
		NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
		[workingDictionary setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
        
        CGImageRef imgRef = [assetRep fullScreenImage];
        UIImage *img = [UIImage imageWithCGImage:imgRef
                                           scale:[UIScreen mainScreen].scale
                                     orientation:(UIImageOrientation)assetRep.orientation];
        [workingDictionary setObject:img forKey:@"UIImagePickerControllerOriginalImage"];
		[workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
		
		[returnArray addObject:workingDictionary];
        
	}
     */
    
    for(ALAsset *asset in assets) {
		NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
		[workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
        
		[returnArray addObject:workingDictionary];
	}
    
    
    
	if(_myDelegate != nil && [_myDelegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)]) {
		[_myDelegate performSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:) withObject:self withObject:[NSArray arrayWithArray:returnArray]];
	} else {
        [self popToRootViewControllerAnimated:NO];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
}

@end

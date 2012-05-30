//
//  SyncService.m
//  OpenPhoto
//
//  Created by Patrick Santana on 24/05/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "SyncService.h"

@interface SyncService()
- (void) loadAssets:(NSMutableArray *) groups;
- (void) loadAssetsGroup;
@end

@implementation SyncService


- (id)init
{
    self = [super init];
    if (self) {
        // for access local images
        assetsLibrary = [[ALAssetsLibrary alloc] init]; 
    }
    return self;
}

- (void) loadLocalImagesOnDatabase
{
    [self loadAssetsGroup];
}


- (void) loadAssets:(NSMutableArray *) groups
{
    // loop in all groups
    NSMutableArray *photos = [[[NSMutableArray alloc] init] autorelease];
    
    for (ALAssetsGroup *group in groups){
        // filter all photos
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // get photos for each group
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) 
         {         
             if(result == nil){
                 return;
             }
             
             // add image
             [photos addObject:result];
         }];
    }
    
    
    // print all photos
    for (ALAsset *photo in photos){
 //       NSLog(@"Image found url = %d", [[photo valueForProperty:ALAssetPropertyURLs] valueForKey:[[[photo valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]]);
    }
}

- (void) loadAssetsGroup
{
    // Load Albums into assetGroups
    // Group enumerator Block
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) 
    {
        if (group == nil){
            return;
        }
 //       [self loadAssets:group];
    };
    
    // Group Enumerator Failure Block
    void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
        NSLog(@"A problem occured %@", [error description]);	                                 
    };	
    
    // Enumerate Albums
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                 usingBlock:assetGroupEnumerator 
                               failureBlock:assetGroupEnumberatorFailure];
    
    
}

- (void)dealloc
{
    [assetsLibrary release];
    [super dealloc];
}
@end

//
//  SyncService.m
//  OpenPhoto
//
//  Created by Patrick Santana on 24/05/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "SyncService.h"

@interface SyncService()
- (void) loadAssets:(ALAssetsGroup *) group;
- (void) loadAssetsGroup;
@end

@implementation SyncService
@synthesize delegate,counter,counterTotal;

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


- (void) loadAssets:(ALAssetsGroup *) group
{
    // load image
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        
        ALAssetRepresentation *rep = [myasset defaultRepresentation];     
        uint8_t* buffer = malloc([rep size]);
        
        NSError* error = NULL;
        NSUInteger bytes = [rep getBytes:buffer fromOffset:0 length:[rep size] error:&error];
        NSData *data = nil;
        
        if (bytes == [rep size]){
            data = [NSData dataWithBytes:buffer length:bytes] ;
            if (data != nil){
                // calculate hash
                NSLog(@"Hash = %@ from group %@",[SHA1 sha1File:data],group);
            }else{
                NSLog(@"Error to get the data from the library");
            }
        }else{
            NSLog(@"Error '%@' reading bytes", [error localizedDescription]);
        }       
        free(buffer);
        
        [pool release];
        
        //calculation to know if it is finished
        self.counter = self.counter - 1;
        
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Conter %d",self.counter);
#endif
        
        if (self.counter <1){
            // finish
            [self.delegate finish];
        }
    };
    
    //
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror){
        NSLog(@"Error '%@' getting asset from library", [myerror localizedDescription]);
    };
    
    // filter all photos
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    
    // get photos for each group
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) 
     {         
         if(result == nil){
             return;
         }
         
         // add image
         [assetsLibrary assetForURL:[[result valueForProperty:ALAssetPropertyURLs] valueForKey:[[[result valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]]
                        resultBlock:resultblock
                       failureBlock:failureblock];
     }];
}
- (void) loadAssetsGroup
{
    self.counter = 0;
    
    // Load Albums into assetGroups
    // Group enumerator Block
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) 
    {
        if (group == nil){
            return;
        }
        
        if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] != ALAssetsGroupPhotoStream){
            // [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            self.counter = self.counter + [group numberOfAssets];
#ifdef DEVELOPMENT_ENABLED
            NSLog(@"Album: %@",group);
#endif
            [self loadAssets:group];
        }
        
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

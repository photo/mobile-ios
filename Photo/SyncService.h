//
//  SyncService.h
//  Photo
//
//  Created by Patrick Santana on 24/05/12.
//  Copyright 2012 Photo
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol SyncServiceDelegate <NSObject>
@required
- (void) information:(NSString*) info;
- (void) finish;
@end

@interface SyncService : NSObject{
    // better to keep here for faster access - schedules the asset read
    ALAssetsLibrary* assetsLibrary;
    id <SyncServiceDelegate> delegate;
    NSInteger counter;
    NSInteger counterTotal;
}

// protocol that will send the response
@property (nonatomic, weak) id delegate;
@property (nonatomic) NSInteger counter;
@property (nonatomic) NSInteger counterTotal;


// it will load all images into the coredata entity SyncPhotos
- (void) loadLocalImagesOnDatabase;

@end

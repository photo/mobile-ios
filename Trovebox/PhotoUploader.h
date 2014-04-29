//
//  PhotoUploader.h
//  Trovebox
//
//  Created by Patrick Santana on 08/06/13.
//  Copyright 2013 Trovebox
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

#import "Synced+Methods.h"
#import "Timeline+Methods.h"

#import "ContentTypeUtilities.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetsLibraryUtilities.h"

@interface PhotoUploader : NSObject

// assets library
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

- (void) loadDataAndSaveEntityUploadDate:(NSDate *) date
                           shareFacebook:(NSNumber *) facebook
                            shareTwitter:(NSNumber *) twitter
                              permission:(NSNumber *) permission
                                    tags:(NSString *) tags
                                  albums:(NSString *) albums
                                   title:(NSString *) title
                                     url:(NSURL *) url
                                groupUrl:(NSString *) urlGroup;

@end

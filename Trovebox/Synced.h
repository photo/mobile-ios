//
//  Synced.h
//  Trovebox
//
//  Created by Patrick Santana on 29/03/13.
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Synced : NSManagedObject

@property (nonatomic, retain) NSString * fileHash;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * userUrl;

@end

//
//  Album.m
//  Trovebox
//
//  Created by Patrick Santana on 09/10/12.
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

#import "Album.h"

@implementation Album

@synthesize name=_name, quantity=_quantity, identification=_identification, thumb=_thumb, selected=_selected;

- (id) initWithAlbumName:(NSString*) name
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.name=name;
        
        // by default no tag is selected. This is used for READ ONLY proposal
        self.selected = NO;
    }
    return self;
}

- (id)initWithAlbumName:(NSString*) name Quantity:(NSInteger) qtd Identification:(NSString *) identification AlbumImageUrl:(NSString *) thumb
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.name=name;
        self.quantity = qtd;
        self.identification = identification;
        self.thumb=thumb;
        
        // by default no tag is selected. This is used for READ ONLY proposal
        self.selected = NO;
    }
    
    return self;
}

@end

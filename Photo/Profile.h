//
//  Profile.h
//  Trovebox
//
//  Created by Patrick Santana on 15/10/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Profile : NSObject

@property (nonatomic) BOOL paid;
@property (nonatomic, strong) NSString *limitRemaining;
@property (nonatomic, strong) NSString *limitAllowed;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *photos;
@property (nonatomic, strong) NSString *albums;
@property (nonatomic, strong) NSString *storage;
@property (nonatomic, strong) NSString *tags;

@property (nonatomic, strong) NSString *photoUrl;

@end

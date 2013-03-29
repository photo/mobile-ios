//
//  Synced.h
//  Trovebox
//
//  Created by Patrick Santana on 29/03/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Synced : NSManagedObject

@property (nonatomic, retain) NSString * fileHash;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * userUrl;

@end

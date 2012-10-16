//
//  Synced.h
//  Photo
//
//  Created by Patrick Santana on 15/10/12.
//  Copyright (c) 2012 Photo Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Synced : NSManagedObject

@property (nonatomic, retain) NSString * fileHash;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * userUrl;

@end

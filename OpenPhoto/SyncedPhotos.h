//
//  SyncedPhotos.h
//  OpenPhoto
//
//  Created by Patrick Santana on 20/07/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SyncedPhotos : NSManagedObject

@property (nonatomic, retain) NSString * fileHash;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * userUrl;

@end

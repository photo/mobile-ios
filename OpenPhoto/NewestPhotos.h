//
//  NewestPhotos.h
//  OpenPhoto
//
//  Created by Patrick Santana on 22/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NewestPhotos : NSManagedObject

@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSData * photoData;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSDate * date;

@end

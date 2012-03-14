//
//  OpenPhotoCoreDataTests.h
//  OpenPhoto
//
//  Created by Patrick Santana on 12/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PhotoModel+OpenPhoto.h"

@interface OpenPhotoCoreDataTests : SenTestCase <NSFetchedResultsControllerDelegate> {
  
@private
    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSFetchedResultsController *fetchedResultsController;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

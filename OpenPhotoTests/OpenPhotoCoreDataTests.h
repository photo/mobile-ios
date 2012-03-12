//
//  OpenPhotoCoreDataTests.h
//  OpenPhoto
//
//  Created by Patrick Santana on 12/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface OpenPhotoCoreDataTests : SenTestCase <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

//
//  OpenPhotoCoreDataTests.m
//  OpenPhoto
//
//  Created by Patrick Santana on 12/03/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "OpenPhotoCoreDataTests.h"


@implementation OpenPhotoCoreDataTests
@synthesize fetchedResultsController, managedObjectContext;

- (void)setUp{
    [super setUp];
}

- (void)tearDown{
    [super tearDown];
}


-(void) testManagedObjectContext{
    if (self.managedObjectContext == nil){
        STFail(@"Managament Object Context is nul");
    }
}

-(void) testInsertIntoPhoto{
    Photos *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:self.managedObjectContext];
    photo.url=@"http://test.com";
    photo.urlSmall=@"http://test2.com";
    photo.date = [NSDate date];
    photo.title = @"This is the title";
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
}

-(void) testCount{
    // bring by id
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photos"];
    
    // sort, it is not necessary. Remove this when we get the getAllPhotos
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!matches)
        STFail(@"Result should not be null");
    
    if ([matches count] == 0 ){
        STFail(@"We should have at least one Photo");
    }
    
    NSLog(@"Count = %i",[matches count]);   
}


- (void) testGetall{
    NSArray *result= [Photos getPhotosInManagedObjectContext:self.managedObjectContext];
    
    if (!result){
        STFail(@"method getPhotosInManagedObjectContext should return some objects");
    }
    
    NSLog(@"Count getPhotosInManagedObjectContext = %i",[result count]);   
}



//////// CORE DATA
#pragma mark -
#pragma mark Core Data stack
- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"OpenPhotoCoreDataTest.sqlite"]];
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil URL:storeUrl options:nil error:&error]) {
        /*Error for store creation should be handled in here*/
        NSLog(@"Error %@",[error localizedDescription]);
    }
    
    return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


@end

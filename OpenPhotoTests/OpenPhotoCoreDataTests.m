//
//  OpenPhotoCoreDataTests.m
//  OpenPhoto
//
//  Created by Patrick Santana on 12/03/12.
//  Copyright 2012 OpenPhoto
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
    PhotoModel *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:self.managedObjectContext];
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
    NSArray *result= [PhotoModel getPhotosInManagedObjectContext:self.managedObjectContext];
    
    if (!result){
        STFail(@"method getPhotosInManagedObjectContext should return some objects");
    }
    
    NSLog(@"Count getPhotosInManagedObjectContext = %i",[result count]);   
}

- (void) testDelete{
    [PhotoModel deleteAllPhotosInManagedObjectContext:self.managedObjectContext];
    
    NSArray *result= [PhotoModel getPhotosInManagedObjectContext:self.managedObjectContext];
    
    if (!result){
        STFail(@"method testDelete should return empty objects");
    }
    
    NSLog(@"Count testDelete = %i",[result count]);  
    
    if ([result count] != 0){
        STFail(@"It should contain 0 objects in the Photos, but it contains %i",[result count]);
    }
}

- (void) testUploads{
    // delete all
    [UploadPhotos deleteAllUploadsInManagedObjectContext:self.managedObjectContext];
    
    // add models with status created, failed, uploaded, uploading
    UploadPhotos *upload = [NSEntityDescription insertNewObjectForEntityForName:@"UploadPhotos" inManagedObjectContext:self.managedObjectContext];
    upload.facebook = NO;
    upload.permission = NO;
    upload.source=UIImagePickerControllerMediaMetadata;
    upload.twitter=NO;
    upload.title=@"Testing";
    upload.date = [NSDate date];
    upload.status=kUploadStatusTypeCreated;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
    
    upload = [NSEntityDescription insertNewObjectForEntityForName:@"UploadPhotos" inManagedObjectContext:self.managedObjectContext];
    upload.facebook = NO;
    upload.permission = NO;
    upload.source=UIImagePickerControllerMediaMetadata;
    upload.twitter=NO;
    upload.title=@"Testing";
    upload.date = [NSDate date];
    upload.status=kUploadStatusTypeFailed;
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
    
    upload = [NSEntityDescription insertNewObjectForEntityForName:@"UploadPhotos" inManagedObjectContext:self.managedObjectContext];
    upload.facebook = NO;
    upload.permission = NO;
    upload.source=UIImagePickerControllerMediaMetadata;
    upload.twitter=NO;
    upload.title=@"Testing";
    upload.date = [NSDate date];
    upload.status=kUploadStatusTypeUploaded;
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
    
    upload = [NSEntityDescription insertNewObjectForEntityForName:@"UploadPhotos" inManagedObjectContext:self.managedObjectContext];
    upload.permission = NO;
    upload.source=UIImagePickerControllerMediaMetadata;
    upload.twitter=NO;
    upload.title=@"Testing";
    upload.date = [NSDate date];
    upload.status=kUploadStatusTypeUploading;
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
    
    //
    // TESTS
    //
    
    // check if there is 4 entites
    if (  [[UploadPhotos getUploadsInManagedObjectContext:self.managedObjectContext] count] !=4 ){
        STFail(@"We should have only 4 items in this list");
    }
    
    // check if there 3 that is not in the state Uploaded
    if (  [[UploadPhotos getUploadsNotUploadedInManagedObjectContext:self.managedObjectContext] count] !=3 ){
        STFail(@"We should have only 3 items in this list");
    }
    
}

- (void) testNewestPhotos{
    // delete all
    [NewestPhotos deleteAllNewestPhotosInManagedObjectContext:self.managedObjectContext];
    
    
    // check size should be 0
    if (  [[NewestPhotos getNewestPhotosInManagedObjectContext:self.managedObjectContext] count] !=0 ){
        STFail(@"We should have no items in this list");
    }
    
    // add one example
    NewestPhotos *photo = [NSEntityDescription insertNewObjectForEntityForName:@"NewestPhotos" 
                                                        inManagedObjectContext:self.managedObjectContext];
    photo.date = [NSDate date];    
    photo.photoUrl = @"http://test.com";
    photo.title =@"Title";
    photo.key=@"Key";
    
   
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
    
    // test if there is ONE item in the list
    if (  [[NewestPhotos getNewestPhotosInManagedObjectContext:self.managedObjectContext] count] !=1 ){
        STFail(@"We should have only 1 item in this list");
    }
    
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
    
    // automatic update
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil URL:storeUrl options:options error:&error]) {
        NSLog(@"Unresolved error with PersistStoreCoordinator %@, %@. Create the persistent file again.", error, [error userInfo]);
        
        // let's recreate it
        [managedObjectContext reset];
        [managedObjectContext lock];
        
        // delete file
        if ([[NSFileManager defaultManager] fileExistsAtPath:storeUrl.path]) {
            if (![[NSFileManager defaultManager] removeItemAtPath:storeUrl.path error:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            } 
        }
        
        [persistentStoreCoordinator release];
        persistentStoreCoordinator = nil;
        
        NSPersistentStoreCoordinator *r = [self persistentStoreCoordinator];
        [managedObjectContext unlock];
        
        return r;
        
    }
    
    return persistentStoreCoordinator;
}


- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


@end

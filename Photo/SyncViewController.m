//
//  SyncViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 18/06/12.
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

#import "SyncViewController.h"

@interface SyncViewController ()
-(void) loadSavedPhotos;
@end

@implementation SyncViewController

@synthesize parent=_parent;
@synthesize assetGroup=_assetGroup, elcAssets=_elcAssets;
@synthesize imagesAlreadyUploaded;
@synthesize tableView=_tableView;

-(void)viewDidLoad
{
    [super viewDidLoad];
	[self.tableView setAllowsSelection:NO];
    self.screenName = @"Sync Screen";
    
    [self.navigationController.navigationBar troveboxStyle:NO];
    
    // table colors
    self.tableView.backgroundColor = UIColorFromRGB(0XFAF3EF);
    self.tableView.separatorColor = UIColorFromRGB(0xCDC9C1);
    
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;
	
	[self.navigationItem setTitle:NSLocalizedString(@"Loading...",@"")];
    
    // title and buttons
    [self.navigationItem troveboxStyle:NSLocalizedString(@"Sync", @"Menu - title for Sync") defaultButtons:YES viewController:self.viewDeckController menuViewController:(MenuViewController*) self.viewDeckController.leftController];
    
    // button to sync
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [UIImage imageNamed:@"next.png"] ;
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    customBarItem.title = @"Next";
    self.navigationItem.rightBarButtonItem = customBarItem;
    
    
    //  UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    //  temporaryBarButtonItem.title = @"Back";
    //  self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
    
    
    // no separator
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    library = [[ALAssetsLibrary alloc] init];
    loaded = NO;
    
    // load all urls
    self.imagesAlreadyUploaded = [Synced getPathsInManagedObjectContext:[SharedAppDelegate managedObjectContext]];
    [self loadSavedPhotos];
}

- (void) viewWillAppear:(BOOL)animated
{
    // refresh profile details
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationProfileRefresh object:nil];
    
    if (loaded == YES){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewDeckController.view animated:YES];
        hud.labelText = @"Loading";
        // load all urls
        self.imagesAlreadyUploaded = [Synced getPathsInManagedObjectContext:[SharedAppDelegate managedObjectContext]];
        [self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
    }else{
        loaded = YES;
    }
    
    // check if users wants to enable auto sync
    if (![[NSUserDefaults standardUserDefaults] valueForKey:kAutoSyncMessageDisplayed] || [[NSUserDefaults standardUserDefaults] boolForKey:kAutoSyncMessageDisplayed] == NO){
        // show message
        // limit reached,
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Enable Auto Sync", nil)
                                                        message: NSLocalizedString(@"Would you like to enable auto sync? Your photos will be upload as private over wifi only.", @"Message to enable auto sync")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"No",nil)
                                              otherButtonTitles:NSLocalizedString(@"Yes",nil), nil];
        [alert show];
    }
    
}

-(void)preparePhotos {
    if (loaded == YES){
        // in the case we had already loaded, let's clean the assets
        // to not have duplicate
        [self.elcAssets removeAllObjects];
    }
    
    @autoreleasepool {
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"enumerating photos");
        NSLog(@"Assets Number %i", assetsNumber);
        NSLog(@"numberOfAssets %i", [self.assetGroup numberOfAssets]);
#endif
        
        if ([self.assetGroup numberOfAssets] != assetsNumber){
            // we need to load again
            [self loadSavedPhotos];
        }else{
            NSMutableArray *startArray = [NSMutableArray array];
            [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
             {
                 if(result == nil)
                 {
                     return;
                 }
                 
                 // check if user already uploaded
                 NSString *asset =  [AssetsLibraryUtilities getAssetsUrlId:result.defaultRepresentation.url] ;
                 
                 BOOL alreadyUploaded = [self.imagesAlreadyUploaded containsObject:asset];
                 ELCAsset *elcAsset = [[ELCAsset alloc] initWithAsset:result alreadyUploaded:alreadyUploaded type:[result valueForProperty:ALAssetPropertyType] duration:[result valueForProperty:ALAssetPropertyDuration]];
                 [elcAsset setParent:self];
                 [startArray addObject:elcAsset];
             }];
            
            //revert the order
            [self.elcAssets addObjectsFromArray:[[startArray reverseObjectEnumerator] allObjects]];
            
            
#ifdef DEVELOPMENT_ENABLED
            NSLog(@"done enumerating photos");
#endif
            [self.tableView reloadData];
            [self.navigationItem setTitle:@"Select Photos"];
            
        }
    }
    
    [MBProgressHUD hideHUDForView:self.viewDeckController.view animated:YES];
}

- (void) doneAction:(id)sender {
	@try {
        NSMutableArray *selectedAssetsImages = [[NSMutableArray alloc] init];
        
        for(ELCAsset *elcAsset in self.elcAssets)
        {
            if([elcAsset selected]) {
                [selectedAssetsImages addObject:[elcAsset asset]];
            }
        }
        
        [self.parent selectedAssets:selectedAssetsImages];
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"UI Action"
                                                                                            action:@"buttonPress"
                                                                                             label:@"Sync - next pressed"
                                                                                             value:nil] build]];
    }@catch (NSException *exception) {
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:@"Error to select your photos" duration:3000];
        [alert showAlert];
        
        NSLog(@"A problem occured when NEXT is clicked on SyncController: %@", [exception description]);
        [self loadSavedPhotos];
    }
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([DisplayUtilities isIPad]){
        return ceil([self.elcAssets count] / 9.0);
    }else{
        return ceil([self.elcAssets count] / 4.0);
    }
}

- (NSArray*)assetsForIndexPath:(NSIndexPath*)_indexPath {
    if ([DisplayUtilities isIPad]){
        int index = (_indexPath.row*9);
        int maxIndex = (_indexPath.row*9+8);
        
        if(maxIndex < [self.elcAssets count]) {
            return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
                    [self.elcAssets objectAtIndex:index+1],
                    [self.elcAssets objectAtIndex:index+2],
                    [self.elcAssets objectAtIndex:index+3],
                    [self.elcAssets objectAtIndex:index+4],
                    [self.elcAssets objectAtIndex:index+5],
                    [self.elcAssets objectAtIndex:index+6],
                    [self.elcAssets objectAtIndex:index+7],
                    [self.elcAssets objectAtIndex:index+8],
                    nil];
        }else if(maxIndex-1 < [self.elcAssets count]) {
            return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
                    [self.elcAssets objectAtIndex:index+1],
                    [self.elcAssets objectAtIndex:index+2],
                    [self.elcAssets objectAtIndex:index+3],
                    [self.elcAssets objectAtIndex:index+4],
                    [self.elcAssets objectAtIndex:index+5],
                    [self.elcAssets objectAtIndex:index+6],
                    [self.elcAssets objectAtIndex:index+7],
                    nil];
        }else if(maxIndex-2 < [self.elcAssets count]) {
            return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
                    [self.elcAssets objectAtIndex:index+1],
                    [self.elcAssets objectAtIndex:index+2],
                    [self.elcAssets objectAtIndex:index+3],
                    [self.elcAssets objectAtIndex:index+4],
                    [self.elcAssets objectAtIndex:index+5],
                    [self.elcAssets objectAtIndex:index+6],
                    nil];
        }else if(maxIndex-3 < [self.elcAssets count]) {
            return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
                    [self.elcAssets objectAtIndex:index+1],
                    [self.elcAssets objectAtIndex:index+2],
                    [self.elcAssets objectAtIndex:index+3],
                    [self.elcAssets objectAtIndex:index+4],
                    [self.elcAssets objectAtIndex:index+5],
                    nil];
        }else if(maxIndex-4 < [self.elcAssets count]) {
            return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
                    [self.elcAssets objectAtIndex:index+1],
                    [self.elcAssets objectAtIndex:index+2],
                    [self.elcAssets objectAtIndex:index+3],
                    [self.elcAssets objectAtIndex:index+4],
                    nil];
        }else if(maxIndex-5 < [self.elcAssets count]) {
            return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
                    [self.elcAssets objectAtIndex:index+1],
                    [self.elcAssets objectAtIndex:index+2],
                    [self.elcAssets objectAtIndex:index+3],
                    nil];
        }else if(maxIndex-6 < [self.elcAssets count]) {
            return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
                    [self.elcAssets objectAtIndex:index+1],
                    [self.elcAssets objectAtIndex:index+2],
                    nil];
        }else if(maxIndex-7 < [self.elcAssets count]) {
            return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
                    [self.elcAssets objectAtIndex:index+1],
                    nil];
        }else if(maxIndex-8 < [self.elcAssets count]) {
            return [NSArray arrayWithObject:[self.elcAssets objectAtIndex:index]];
        }
        
        
    }else{
        int index = (_indexPath.row*4);
        int maxIndex = (_indexPath.row*4+3);
        
        if(maxIndex < [self.elcAssets count]) {
            return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
                    [self.elcAssets objectAtIndex:index+1],
                    [self.elcAssets objectAtIndex:index+2],
                    [self.elcAssets objectAtIndex:index+3],
                    nil];
        }else if(maxIndex-1 < [self.elcAssets count]) {
            return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
                    [self.elcAssets objectAtIndex:index+1],
                    [self.elcAssets objectAtIndex:index+2],
                    nil];
        }else if(maxIndex-2 < [self.elcAssets count]) {
            return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
                    [self.elcAssets objectAtIndex:index+1],
                    nil];
        }else if(maxIndex-3 < [self.elcAssets count]) {
            return [NSArray arrayWithObject:[self.elcAssets objectAtIndex:index]];
        }
    }
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    ELCAssetCell *cell = (ELCAssetCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
        cell = [[ELCAssetCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }else{
		[cell setAssets:[self assetsForIndexPath:indexPath]];
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	return 79;
}

- (int)totalSelectedAssets {
    
    int count = 0;
    
    for(ELCAsset *asset in self.elcAssets)
    {
		if([asset selected])
        {
            count++;
		}
	}
    
    return count;
}

- (void) loadSavedPhotos
{
    // the Saved Photos Album
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       // Group enumerator Block
                       void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
                       {
                           if (group == nil)
                           {
                               return;
                           }
                           
                           if ( [[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
                               self.assetGroup = group;
                               // just bring photos
                               [self.assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                               
                               MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewDeckController.view animated:YES];
                               hud.labelText = NSLocalizedString(@"Loading", nil);
                               assetsNumber = [self.assetGroup numberOfAssets];
                               
                               // with the local group, we can load the images
                               [self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
                           }
                       };
                       
                       // Group Enumerator Failure Block
                       void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                           
                           UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                           [alert show];
                           
                           NSLog(@"A problem occured %@", [error description]);
                       };
                       
                       // Show only the Saved Photos
                       [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                              usingBlock:assetGroupEnumerator
                                            failureBlock:assetGroupEnumberatorFailure];
                       
                   });
    
}

// Sync
#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Selected some images");
#endif
    
    if (info != nil && [info count]>0 ){
        // convert to nsarray
        NSMutableArray *urls = [NSMutableArray array];
        for(NSDictionary *dict in info) {
            [urls addObject:[dict objectForKey:UIImagePickerControllerReferenceURL]];
        }
        
        PhotoViewController* controller = [[PhotoViewController alloc]initWithNibName:[DisplayUtilities getCorrectNibName:@"PhotoViewController"] bundle:nil images:urls];
        [picker pushViewController:controller animated:YES];
    }else{
        // no photo select
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:@"Please select at least 1 photo." duration:5000];
        [alert showAlert];
    }
    
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    // this one is not used.
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Cancel Sync");
#endif
}


- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - Rotation

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (buttonIndex == 1){
        // Yes
        [standardUserDefaults setBool:YES forKey:kAutoSyncEnabled];
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"UI Action"
                                                                                            action:@"buttonPress"
                                                                                             label:@"Auto Sync - select YES"
                                                                                             value:nil] build]];
    }else{
        // No
        [standardUserDefaults setBool:NO forKey:kAutoSyncEnabled];
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"UI Action"
                                                                                            action:@"buttonPress"
                                                                                             label:@"Auto Sync - select NO"
                                                                                             value:nil] build]];
    }
    
    // set any value in the variable that we showed the message
    [standardUserDefaults setBool:YES forKey:kAutoSyncMessageDisplayed];
}
@end

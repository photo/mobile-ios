//
//  AssetTablePicker.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCAlbumPickerController.h"


@implementation ELCAssetTablePicker

@synthesize parent;
@synthesize assetGroup, elcAssets;
@synthesize imagesAlreadyUploaded;

-(void)viewDidLoad {
    
	[self.tableView setAllowsSelection:NO];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;
    [tempArray release];
	
	[self.navigationItem setTitle:@"Loading..."];
    
    // button to sync
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [UIImage imageNamed:@"syncButton.png"] ;
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button]; 
    self.navigationItem.rightBarButtonItem = customBarItem;
    [customBarItem release];
    
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackOpaque;
    
    // image for the navigator
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]){
        //iOS >=5.0
        UIImage *backgroundImage= [UIImage imageNamed:@"appbar_empty.png"];
        [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    }
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];   
    
    
    self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"BackgroundUpload.png"]];
    
    // no separator
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    library = [[ALAssetsLibrary alloc] init]; 
    loaded = NO;
    
    // load all urls
    self.imagesAlreadyUploaded = [SyncPhotos getPathsInManagedObjectContext:[AppDelegate managedObjectContext]];
    
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
                               [self.assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                               [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                               // with the local group, we can load the images                           
                               [self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
                           }
                       };
                       
                       // Group Enumerator Failure Block
                       void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                           
                           UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                           [alert show];
                           [alert release];
                           
                           NSLog(@"A problem occured %@", [error description]);	                                 
                       };	
                       
                       // Show only the Saved Photos
                       [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                              usingBlock:assetGroupEnumerator 
                                            failureBlock:assetGroupEnumberatorFailure];
                       
                   });      
}


- (void) viewWillAppear:(BOOL)animated
{
    if (loaded == YES){
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        // load all urls
        self.imagesAlreadyUploaded = [SyncPhotos getPathsInManagedObjectContext:[AppDelegate managedObjectContext]];
        [self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
        
    }else{
        loaded = YES;
    }
}

-(void)preparePhotos {
    if (loaded == YES){
        // in the case we had already loaded, let's clean the assets
        // to not have duplicate
        [self.elcAssets removeAllObjects];
    }
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
#ifdef DEVELOPMENT_ENABLED 
    NSLog(@"enumerating photos");
#endif
    
    [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) 
     {         
         if(result == nil) 
         {
             return;
         }
         
         // check if user already uploaded
         NSString *asset =  [AssetsLibraryUtilities getAssetsUrlId:result.defaultRepresentation.url] ;
         
         ELCAsset *elcAsset = [[ELCAsset alloc] initWithAsset:result alreadyUploaded:[self.imagesAlreadyUploaded containsObject:asset]];
         [elcAsset setParent:self];
         [self.elcAssets addObject:elcAsset];
         [elcAsset release];
     }];   
    
#ifdef DEVELOPMENT_ENABLED     
    NSLog(@"done enumerating photos");
#endif
    
    [self.tableView reloadData];
    [self.navigationItem setTitle:@"Pick Photos"];
    
    [pool release];
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

- (void) doneAction:(id)sender {
	
	NSMutableArray *selectedAssetsImages = [[[NSMutableArray alloc] init] autorelease];
    
	for(ELCAsset *elcAsset in self.elcAssets) 
    {		
		if([elcAsset selected]) {
			[selectedAssetsImages addObject:[elcAsset asset]];
		}
	}
    
    [(ELCAlbumPickerController*)self.parent selectedAssets:selectedAssetsImages];
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ceil([self.elcAssets count] / 4.0);
}

- (NSArray*)assetsForIndexPath:(NSIndexPath*)_indexPath {
    
	int index = (_indexPath.row*4);
	int maxIndex = (_indexPath.row*4+3);
    
	if(maxIndex < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				[self.elcAssets objectAtIndex:index+2],
				[self.elcAssets objectAtIndex:index+3],
				nil];
	}
    
	else if(maxIndex-1 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				[self.elcAssets objectAtIndex:index+2],
				nil];
	}
    
	else if(maxIndex-2 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				nil];
	}
    
	else if(maxIndex-3 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObject:[self.elcAssets objectAtIndex:index]];
	}
    
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {		        
        cell = [[[ELCAssetCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] reuseIdentifier:CellIdentifier] autorelease];
    }	
	else 
    {		
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

- (void)dealloc 
{
    [elcAssets release];
    [library release];
    [self.assetGroup release];
    [self.imagesAlreadyUploaded release];
    [super dealloc];    
}

@end

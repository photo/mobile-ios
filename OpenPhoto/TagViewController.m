//
//  TagViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 11/08/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "TagViewController.h"


@implementation TagViewController

@synthesize tags, service;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // create the service
        self.service = [[WebService alloc]init];
        [service setDelegate:self];

        
        // initialize the object tags
        self.tags = [[NSMutableArray alloc]init];      
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) dealloc{
    [tags release];
    [service release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // set the tile of the table
    self.title=@"Tags"; 
    
    // load all tags
    [service getTags];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



#pragma mark - Delegate for bring the tags from the server
- (void) receivedResponse:(NSDictionary*) response{
    NSArray *tagsResult = [response objectForKey:@"result"] ;
    
    // Loop through each entry in the dictionary and create an array Tags
    for (NSDictionary *tagDetails in tagsResult){
        // tag name       
        NSString *name = [tagDetails objectForKey:@"id"];
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        Tag *tag = [[Tag alloc]initWithTagName:name];
        [tags addObject:tag];
        [tag release];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    NSUInteger row = [indexPath row];
    
    Tag *tag = [tags objectAtIndex:row];
    cell.textLabel.text=tag.tagName;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the tag
    NSUInteger row = [indexPath row];
    Tag *tag = [tags objectAtIndex:row];
    
    // open the gallery with a tag
    GalleryViewController *galleryController = [[GalleryViewController alloc]initWithTagName:tag.tagName];
    [self.navigationController pushViewController:galleryController animated:YES];
    [galleryController release];
}

@end

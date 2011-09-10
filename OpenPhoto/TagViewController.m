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
        
        readOnly = NO;
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
- (void) setReadOnly{
    readOnly = YES;
}

// this method return only the tag's name.
- (NSArray*) getSelectedTags{
    NSMutableArray *array = [NSMutableArray array];
    
    for (id object in self.tags) {
        Tag *tag = (Tag*) object;
        if (tag.selected == YES){
            [array addObject:tag.tagName];   
        }
    }
    
    return array;
}

// this method return the tag's name but in the format to send to openphoto server
- (NSString *) getSelectedTagsInJsonFormat{  
    NSMutableString *result = [NSMutableString string];
    [result appendFormat:@"["];
    
    NSArray *array = [self getSelectedTags];
    int counter = 1;
    
    if (array != nil && [array count]>0){
        for (id string in array) {
            [result appendFormat:@"%@%@%@",@"'",string,@"'"];
            
            // add the ,
            if ( counter < [array count]){
                [result appendFormat:@", "];
            }
            
            counter++;
        }
    }
    
    [result appendFormat:@"]"];
    return result;
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
        
        // how many images
        NSString *qtd = [tagDetails objectForKey:@"count"];
        
        // create a tag and add to the list
        Tag *tag = [[Tag alloc]initWithTagName:name Quantity:[qtd integerValue]];
        [tags addObject:tag];
        
        // we don't need it anymore.
        [tag release];
    }
    
    [self.tableView reloadData];
}

- (void) notifyUserNoInternet{
    // problem with internet, show message to user
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet error" message:@"Couldn't reach the server. Please, check your internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    NSUInteger row = [indexPath row];
    
    Tag *tag = [tags objectAtIndex:row];
    cell.textLabel.text=tag.tagName;
    if (readOnly == NO){
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%d", tag.quantity];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the tag
    NSUInteger row = [indexPath row];
    Tag *tag = [tags objectAtIndex:row];
    
    if (tag.quantity >0 && readOnly == NO){
        // open the gallery with a tag that contains at least one picture.
        GalleryViewController *galleryController = [[GalleryViewController alloc]initWithTagName:tag.tagName];
        [self.navigationController pushViewController:galleryController animated:YES];
        [galleryController release];
    }
    
    if (readOnly == TRUE){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSUInteger row = [indexPath row];
        Tag *tag = [tags objectAtIndex:row];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            tag.selected = NO;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            tag.selected = YES;
        }
    }
}

@end

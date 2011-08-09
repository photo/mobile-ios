
#import "TagsViewController.h"

@interface TagsViewController()
- (void)searchTestController:(TagsViewController*)controller didSelectObject:(id)object;
@end

@implementation TagsViewController
@synthesize service;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"Search Tags";
        self.dataSource = [[[MockDataSource alloc] init] autorelease];
    }
    return self;
}

- (void)dealloc {
    [service release];
	[super dealloc];
}

// PROTOCOL TO RECEIVE THE TAGS
-(void) receivedResponse:(NSDictionary *)response{
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
    [super loadView];
    
    TTTableViewController* searchController = [[[TTTableViewController alloc] init] autorelease];
    searchController.dataSource = [[[MockSearchDataSource alloc] initWithDuration:0.5] autorelease];
    self.searchViewController = searchController;
    self.tableView.tableHeaderView = _searchController.searchBar;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
    [self searchTestController:self didSelectObject:object];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTSearchTextFieldDelegate

- (void)textField:(TTSearchTextField*)textField didSelectObject:(id)object {
    [self searchTestController:self didSelectObject:object];
}

//////// Actions when the item is selected
- (void)searchTestController:(TagsViewController*)controller didSelectObject:(id)object{
    NSLog(@"Row selected");
    GalleryViewController *galleryController = [[[GalleryViewController alloc]init] autorelease];
    [self.navigationController pushViewController:galleryController animated:YES];
}

@end

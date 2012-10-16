//
//  ViewController.m
//  ViewDeckExample
//

#import "ViewController.h"
#import "IIViewDeckController.h"

@interface ViewController () <UIImagePickerControllerDelegate>

@end

@implementation ViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleLeftView)];
    
    if ([self.navigationItem respondsToSelector:@selector(rightBarButtonItems)]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
                                                   [[UIBarButtonItem alloc] initWithTitle:@"Sync" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleRightView)],
                                                   nil];
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sync" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleRightView)];
    }
    
    // Custom initialization
    self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Background.png"]];
    
    // color separator
    self.tableView.separatorColor = UIColorFromRGB(0xC8BEA0);
    
    // title
    self.navigationItem.title = NSLocalizedString(@"OpenPhoto", @"Main page title");

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return !section ? @"Left" : @"Right";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.textAlignment = indexPath.section ? NSTextAlignmentRight : NSTextAlignmentLeft;
    cell.textLabel.text = [NSString stringWithFormat:@"ledge: %d", indexPath.row*44];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.section) {
        self.viewDeckController.leftLedge = MAX(indexPath.row*44,10);
    }
    else {
        self.viewDeckController.rightLedge = MAX(indexPath.row*44,10);
    }
}

@end

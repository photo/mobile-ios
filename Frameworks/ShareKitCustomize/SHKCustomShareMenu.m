//
//  SHKCustomShareMenu.m
//  RIL
//
//  Created by Nathan Weiner on 6/30/10.

//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import "SHKCustomShareMenu.h"

@implementation SHKCustomShareMenu


// See http://getsharekit.com/customize/ for additional information on customizing

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"BackgroundUpload.png"]];
    self.tableView.separatorColor = UIColorFromRGB(0xC8BEA0);	
    
}

- (void) viewWillAppear:(BOOL)animated
{
    // image for the navigator
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]){
        //iOS >=5.0
        UIImage *backgroundImage = [UIImage imageNamed:@"appbar_empty.png"];
        [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    }
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackOpaque;
    self.navigationController.navigationController.navigationBar.barStyle=UIBarStyleBlackOpaque;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
}

// Customize the look of the cell
- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    SHKCustomFormFieldCell *cell = 
    (SHKCustomFormFieldCell *)[super tableView:tableView
                         cellForRowAtIndexPath:indexPath];
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
    
    return cell;
}


// Set the height of our label (when we have one to display)
- (CGFloat)tableView:(UITableView *)tableView 
heightForFooterInSection:(NSInteger)section
{
    NSString *footerTitle = [self tableView:tableView 
                    titleForFooterInSection:section];
    if (footerTitle != nil)
        return 50;
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Get the text
    NSString *text = [super tableView:tableView titleForHeaderInSection:section];
    
    // create the parent view that will hold header Label
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
	
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.textColor = UIColorFromRGB(0xE6501E);
	headerLabel.font = [UIFont boldSystemFontOfSize:18];
	headerLabel.frame = CGRectMake(18.0, 0.0, 300.0, 44.0);
    
    
	headerLabel.text = text;
	[customView addSubview:headerLabel];
    
	return customView;
}

@end

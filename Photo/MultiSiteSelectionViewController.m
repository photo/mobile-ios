//
//  MultiSiteSelectionViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 15/10/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "MultiSiteSelectionViewController.h"

@interface MultiSiteSelectionViewController ()

@property (nonatomic, strong) NSArray *accounts;

@end

@implementation MultiSiteSelectionViewController
@synthesize accounts=_accounts;
-(id) initWithAccounts:(NSArray*) accounts
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self){
        _accounts = accounts;
        self.title=@"Select a Trovebox account";
        
    }
    
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor =  UIColorFromRGB(0x44291A);
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Account *account =[_accounts objectAtIndex:indexPath.row];
    cell.textLabel.text = [account.host stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    NSLog(@"Profile photo %@", account.profile.photoUrl);
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:account.profile.photoUrl] placeholderImage:[UIImage imageNamed:@"empty_img.png"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the account
    NSUInteger row = [indexPath row];
    Account *account = [self.accounts objectAtIndex:row];
    
    // save locally
    [account saveToStandardUserDefaults];
    
    // send notification to the system that it can shows the screen:
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginAuthorize object:nil ];
}

- (void)tableView:(UITableView *)tableView   willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


@end

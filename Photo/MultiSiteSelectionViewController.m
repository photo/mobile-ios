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
        self.title=@"Select account";
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
    static NSString *CellIdentifier = @"MultiSiteSelectionCell";
    Account *account =[_accounts objectAtIndex:indexPath.row];
    
    if ([DisplayUtilities isIPad]){
        // if iPad just use the simple cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        
        cell.textLabel.text = [account.host stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        cell.textLabel.textColor = [UIColor whiteColor];
        
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Profile photo %@", account.profile.photoUrl);
#endif
        
        [cell.imageView setImageWithURL:[NSURL URLWithString:account.profile.photoUrl] placeholderImage:[UIImage imageNamed:@"empty_img.png"] completed:nil];

        return cell;
    }else{
        // if iPhone uses a more complex
        MultiSiteSelectionCell *multiSiteSelectionCell = (MultiSiteSelectionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (multiSiteSelectionCell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MultiSiteSelectionCell" owner:nil options:nil];
            multiSiteSelectionCell = [topLevelObjects objectAtIndex:0];
        }
        
        multiSiteSelectionCell.host.text=[account.host stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        
        multiSiteSelectionCell.type.text=account.type;
        
         [multiSiteSelectionCell.userImage setImageWithURL:[NSURL URLWithString:account.profile.photoUrl] placeholderImage:[UIImage imageNamed:@"empty_img.png"] completed:nil];
        
        return multiSiteSelectionCell;
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
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

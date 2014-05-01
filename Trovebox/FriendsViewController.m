//
//  MultiSiteSelectionViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 15/10/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "FriendsViewController.h"

@interface FriendsViewController ()

@property (nonatomic, strong) NSArray *friends;

@end

@implementation FriendsViewController
@synthesize friends=_friends;
-(id) init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self){
       // _accounts = accounts;
        
        /*
        jmathai.trvbx.co
        anurag.trvbx.co
        psantana.trvbx.co
        rthomas.trvbx.co
        cmathai.trvbx.co
         */
        self.title=@"Select friend";
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
    return [_friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendsCell";
    Friend *friend =[_friends objectAtIndex:indexPath.row];
    
    if ([DisplayUtilities isIPad]){
        // if iPad just use the simple cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        
        cell.textLabel.text = [friend.host stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        cell.textLabel.textColor = [UIColor whiteColor];
        [cell.imageView setImageWithURL:[NSURL URLWithString:friend.photoUrl] placeholderImage:[UIImage imageNamed:@"empty_img.png"] completed:nil];
        
        return cell;
    }else{
        // if iPhone uses a more complex
        FriendsCell *cell = (FriendsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FriendsCell" owner:nil options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        cell.host.text=[friend.host stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        cell.name.text = friend.name;
        [cell.userImage setImageWithURL:[NSURL URLWithString:friend.photoUrl] placeholderImage:[UIImage imageNamed:@"empty_img.png"] completed:nil];
        
        return cell;
        
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
    Friend *friend = [self.friends objectAtIndex:row];
    
    // open friend

}

- (void)tableView:(UITableView *)tableView   willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


@end

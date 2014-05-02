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
        Friend *friend1 = [[Friend alloc] initWithHost:@"jmathai.trvbx.co" name:@"Jaisen's Site" userName:@"jmathai" photoUrl:@"http://jmathai.trvbx.co/photos/custom/201007/Boracay-Philippines-005-5f368f_100x100xCR.jpg"];
        Friend *friend2 = [[Friend alloc] initWithHost:@"anurag.trvbx.co" name:@"Anurag" userName:@"anurag" photoUrl:@"http://anurag.trvbx.co/photos/custom/201404/Screenshot-2013-12-12-16.59.15-87aef2_100x100xCR.jpg"];
        Friend *friend3 = [[Friend alloc] initWithHost:@"rthomas.trvbx.co" name:@"Trovebox User" userName:@"rthomas" photoUrl:@"http://www.gravatar.com/avatar/197a713e7c8b60dc83c4053597997190?s=100&d=http%3A%2F%2Fcmathai.trvbx.co%2Fassets%2Fthemes%2Ffabrizio1.0%2Fimages%2Fprofile-default.png"];
        Friend *friend4 = [[Friend alloc] initWithHost:@"cmathai.trvbx.co" name:@"Cecil Mathai" userName:@"cmathai" photoUrl:@"http://www.gravatar.com/avatar/197a713e7c8b60dc83c4053597997190?s=100&d=http%3A%2F%2Fcmathai.trvbx.co%2Fassets%2Fthemes%2Ffabrizio1.0%2Fimages%2Fprofile-default.png"];
        
        _friends = @[friend1, friend2, friend3,friend4];
        self.title=@"Select friend";
    }
    
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor =  UIColorFromRGB(0XFAF3EF);
    
    // image for the navigator
    [self.navigationController.navigationBar troveboxStyle:NO];
    
    // title and buttons
    [self.navigationItem troveboxStyle:NSLocalizedString(@"Friends", @"Menu - title for Friends") defaultButtons:YES viewController:self.viewDeckController menuViewController:(MenuViewController*) self.viewDeckController.leftController];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = UIColorFromRGB(0x3B2414);
    self.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(loadFriends) forControlEvents:UIControlEventValueChanged];
    
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
    UINavigationController *nav;
    if ([DisplayUtilities isIPad]){
        nav = [[UINavigationController alloc]initWithRootViewController:[[FriendDetailsViewController alloc] initWithNibName:@"FriendDetailsViewControlleriPad" bundle:nil friend:friend]];
    }else{
        nav = [[UINavigationController alloc]initWithRootViewController:[[FriendDetailsViewController alloc] initWithNibName:@"FriendDetailsViewController" bundle:nil friend:friend]];
    }

    self.viewDeckController.centerController = nav;
    [NSThread sleepForTimeInterval:(300+arc4random()%700)/1000000.0]; // mimic delay... not really necessary
    
}

- (void)tableView:(UITableView *)tableView   willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark
#pragma mark - Methods to get friends via json
- (void) loadFriends
{
    // if there isn't netwok
    if ( [SharedAppDelegate internetActive] == NO ){
        // problem with internet, show message to user
        PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:NSLocalizedString(@"Please check your internet connection",@"") duration:5000];
        [alert showAlert];
        [self.refreshControl endRefreshing];
    }else {
        // add code to refresh the list
        [self.refreshControl endRefreshing];
    }
}


@end

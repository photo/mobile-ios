//
//  PhotoViewController.m
//  Trovebox
//
//  Created by Patrick Santana on 29/07/11.
//  Copyright 2013 Trovebox
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "PhotoViewController.h"

@interface PhotoViewController()
- (void) switchedFacebook;
- (void) switchedTwitter;
- (void)upload:(id)sender;

@end

@implementation PhotoViewController

@synthesize detailsPictureTable=_detailsPictureTable;
@synthesize titleTextField=_titleTextField, permissionPicture=_permissionPicture, shareFacebook=_shareFacebook, shareTwitter=_shareTwitter;
@synthesize tagController=_tagController, albumController=_albumController;

@synthesize image= _image;
@synthesize images = _images;

// to upload
@synthesize uploader=_uploader;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL *) imageFromCamera
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        self.image = imageFromCamera;
        self.uploader = [[PhotoUploader alloc] init];
        
        // initialization of tag controller
        self.tagController = [[TagViewController alloc] init];
        [self.tagController setReadOnly];
        
        // initialization of algum controller
        self.albumController = [[AlbumViewController alloc] init];
        [self.albumController setReadOnly];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil images:(NSArray *) imagesFromSync
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        self.images = imagesFromSync;
        self.uploader = [[PhotoUploader alloc] init];
        
        // how many images we need to process?
        if (self.images){
            // if there is only one, treat it as a camera image, so user will be able to edit
            if ([self.images count] == 1){
                self.image = [self.images lastObject];
            }
        }
        
        // initialization of tag controller
        self.tagController = [[TagViewController alloc] init];
        [self.tagController setReadOnly];
        
        // initialization of algum controller
        self.albumController = [[AlbumViewController alloc] init];
        [self.albumController setReadOnly];
    }
    return self;
}


#pragma mark - View lifecycle
- (void)viewDidLoad{
    [super viewDidLoad];
    self.screenName = @"Upload Screen";
    
    [self.navigationItem troveboxStyle:NSLocalizedString(@"Upload", @"Title in the upload form") defaultButtons:NO viewController:nil menuViewController:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (self.images){
        self.detailsPictureTable.frame = CGRectMake(self.detailsPictureTable.frame.origin.x,self.detailsPictureTable.frame.origin.y - 40, self.detailsPictureTable.frame.size.width,self.detailsPictureTable.frame.size.height+40);
    }else{
        // if user wants to cancel the upload
        // it should be just in the case of snapshot
        // button CLOSE
        UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Close on Upload") style:UIBarButtonItemStylePlain target:self action:@selector(cancelUploadButton)];
        self.navigationItem.leftBarButtonItem = customBarItem;
    }
    
    // button DONE
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done on Upload") style:UIBarButtonItemStylePlain target:self action:@selector(upload:)];
    self.navigationItem.rightBarButtonItem = customBarItem;
    
    self.detailsPictureTable.backgroundColor =  UIColorFromRGB(0XFAF3EF);
    self.view.backgroundColor =  UIColorFromRGB(0XFAF3EF);
}


- (void) cancelUploadButton{
    [self dismissViewControllerAnimated:YES completion:^{
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"UI Action"
                                                                                            action:@"buttonPress"
                                                                                             label:@"Cancel Upload"
                                                                                             value:nil] build]];
    }];
}

-(IBAction)OnClick_btnBack:(id)sender  {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload{
    [self setLabelLimitUpload:nil];
    [super viewDidUnload];
    [self setDetailsPictureTable:nil];
}

#pragma mark - Rotation

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([SharedAppDelegate isProUser] || ![SharedAppDelegate isHosted]){
        self.labelLimitUpload.hidden = TRUE;
    }else{
        self.labelLimitUpload.hidden = FALSE;
        
        // set lable for the limit
        NSString *message;
        if ([SharedAppDelegate limitFreeUser] == 1){
            message = NSLocalizedString(@"You can upload one more photo this month",@"Message limit - one more photo");
        }else if([SharedAppDelegate limitFreeUser] > 1){
            message = [NSString stringWithFormat:NSLocalizedString(@"You can upload %d more photos this month",@"Message limit - n more photos"), [SharedAppDelegate limitFreeUser]];
        }else{
            message = [NSString stringWithFormat:NSLocalizedString(@"You've reached your monthly limit of 100 photos",@"Message when limit is reached on upload screen")];
        }
        
        self.labelLimitUpload.text = message;
    }
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    NSUInteger row = [indexPath row];
    switch (row) {
        case 0:
            // title
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierTitle];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierTitle];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                
                // position based if it is ipad or not
                CGRect position;
                if ([DisplayUtilities isIPad])
                    position = CGRectMake(55 , 13, 460, 21);
                else
                    position = CGRectMake(17 , 13, 260, 21);
                
                self.titleTextField = [[UITextField alloc] initWithFrame:position];
                self.titleTextField.adjustsFontSizeToFitWidth = YES;
                self.titleTextField.textColor = UIColorFromRGB(0x8C7B73);
                
                self.titleTextField.placeholder = NSLocalizedString(@"title",@"Upload - inside text input");
                self.titleTextField.keyboardType = UIKeyboardTypeDefault;
                self.titleTextField.returnKeyType = UIReturnKeyNext;
                self.titleTextField.delegate = self;
                [cell addSubview:self.titleTextField];
            }
            break;
        case 1:
            // tags
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierTags];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierTags];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=NSLocalizedString(@"Tags",nil);
            // customised disclosure button
            [cell setAccessoryView:[self makeDetailDisclosureButton]];
            break;
            
        case 2:
            // albums
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierAlbums];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierAlbums];
            }
            
            cell.textLabel.text=NSLocalizedString(@"Albums",nil);
            // customised disclosure button
            [cell setAccessoryView:[self makeDetailDisclosureButton]];
            break;
            
        case 3:
            // private flag
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierPrivate];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierPrivate];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=NSLocalizedString(@"Private",@"Upload - Private");
            self.permissionPicture = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = self.permissionPicture;
            [self.permissionPicture setOnTintColor:UIColorFromRGB(0xEFC005)];
            
            // get from user configuration if pictures should be private or not
            [(UISwitch *)cell.accessoryView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kPhotosArePrivate]];
            break;
            
        case 4:
            // Facebook
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierShareFacebook];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierShareFacebook];
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=NSLocalizedString(@"Facebook",@"Upload - Facebook");
            self.shareFacebook = [[UISwitch alloc] initWithFrame:CGRectZero];
            [self.shareFacebook setOnTintColor:UIColorFromRGB(0xEFC005)];
            [self.shareFacebook addTarget:self action:@selector(switchedFacebook) forControlEvents:UIControlEventValueChanged];
            [self.shareFacebook setOn:NO];
            cell.accessoryView = self.shareFacebook;
            break;
            
        case 5:
            // Twitter
            cell=[tableView dequeueReusableCellWithIdentifier:kCellIdentifierShareTwitter];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierShareTwitter] ;
                // Do anything that should be the same on EACH cell here.  Fonts, colors, etc.
            }
            
            cell.textLabel.text=NSLocalizedString(@"Twitter",@"Upload - Twitter");
            self.shareTwitter = [[UISwitch alloc] initWithFrame:CGRectZero];
            [self.shareTwitter setOnTintColor:UIColorFromRGB(0xEFC005)];
            [self.shareTwitter addTarget:self action:@selector(switchedTwitter) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = self.shareTwitter;
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (UIButton *) makeDetailDisclosureButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // set the image
    UIImage *image = [UIImage imageNamed:@"button-disclosure-form.png"];
    [button setImage:image forState:UIControlStateNormal];
    
    CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.frame = frame;
    
    // action
    [button addTarget: self
               action: @selector(accessoryButtonTapped:withEvent:)
     forControlEvents: UIControlEventTouchUpInside];
    
    return button;
}

- (void) accessoryButtonTapped: (UIControl *) button withEvent: (UIEvent *) event{
    NSIndexPath * indexPath = [self.detailsPictureTable indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.detailsPictureTable]];
    if ( indexPath == nil )
        return;
    
    [self.detailsPictureTable.delegate tableView: self.detailsPictureTable accessoryButtonTappedForRowWithIndexPath: indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    if (row == 1){
        // tags
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:0];
        [self.navigationController pushViewController:self.tagController animated:YES];
    }else if (row == 2){
        // albums
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:0];
        [self.navigationController pushViewController:self.albumController animated:YES];
    }
}

-(void) switchedFacebook{
    if ([self.shareFacebook isOn]){
        [self.shareTwitter setOn:NO animated:YES];
    }
}

-(void) switchedTwitter{
    if ([self.shareTwitter isOn]){
        [self.shareFacebook setOn:NO animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)upload:(id)sender {
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"UI Action"
                                                                                        action:@"buttonPress"
                                                                                         label:@"Upload"
                                                                                         value:nil] build]];
    
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Upload button clicked. Save all details in the database");
#endif
    
    // values
    NSNumber *facebook = ([self.shareFacebook isOn] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO]) ;
    NSNumber *twitter = ([self.shareTwitter isOn] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO]);
    NSNumber *permission = (![self.permissionPicture isOn] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO]);
    NSString *title = self.titleTextField.text.length > 0 ? self.titleTextField.text : nil;
    NSString *tags = [self.tagController getSelectedTagsInJsonFormat];
    NSString *albums = [self.albumController getSelectedAlbumsIdentification];
    
    
    NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:kTroveboxTypeUser];
    if (type && [type isEqualToString:@"group"] && [SharedAppDelegate isHosted]){
        // user needs to select an album
        // if there is no album, he can't upload
        Account *account = [[Account alloc]init];
        [account readFromStandardUserDefaults];
        
        // now we should have access to all information from this user
        Permission *permission = account.permission;
        if ([permission.c isKindOfClass:[NSArray class]]){
            // has one or more albums that he can upload.
            if ([permission.c count] == 1){
                            // if there is one, needs to set this one as identifier
                id albumAllowed = [permission.c objectAtIndex:0];
                if ([albumAllowed isKindOfClass:[NSString class]]){
                    albums = [permission.c objectAtIndex:0];
                } else{
                    albums = [[permission.c objectAtIndex:0] stringValue];
                }
            }else{
                // check if it is one of the selected
                NSArray *albumsAllowed = permission.c;
                
                // if not, ask user to select one
                BOOL found=NO;
                for (id s in albumsAllowed)
                {
                    if ([s isKindOfClass:[NSString class]]){
                        if ([albums rangeOfString:s].location != NSNotFound) {
                            found = YES;
                            break;
                        }
                    } else{
                        if ([albums rangeOfString:[s stringValue]].location != NSNotFound) {
                            found = YES;
                            break;
                        }
                    }
                }
                
                if (!found){
                    // show message and return
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
                                                                    message: NSLocalizedString(@"Please select an album.", @"Message to select one album to upload your photos")
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
                    [alert show];
                    return;
                }
                    
            }
        }else if ([permission.c isKindOfClass:[NSNumber class]]){
            // if 1, YES for all
            // if 0, NO for all, so just display an alert he doesn't have permission and return
        }
        
    }
    
    dispatch_queue_t waiting = dispatch_queue_create("waiting_finish_insert_database", NULL);
    dispatch_async(waiting, ^{
        @try {
            //
            //
            // Process all images in a queue.
            // When necessary to run in the main thread, do it
            // during this time, user will have a progress bar, so, no possible to change values
            //
            //
            
            // check the type of image that we are uploading
            // is it a single image or a bunch of images?
            if (self.images && [self.images count]>1){
                // bunch of photos and more than one
                int i = [self.images count];
                for ( NSURL *url in self.images){
                    if ( i != 1 ){
                        [self.uploader loadDataAndSaveEntityUploadDate:[NSDate date]
                                                         shareFacebook:[NSNumber numberWithBool:NO]
                                                          shareTwitter:[NSNumber numberWithBool:NO]
                                                            permission:permission
                                                                  tags:tags
                                                                albums:albums
                                                                 title:title
                                                                   url:url
                                                              groupUrl:nil];
                        
                        
                    }else{
                        // this is the last one,
                        // so we do the sharing if needed
                        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                        
                        // create the url to connect to OpenPhoto
                        NSString *urlString =     [NSString stringWithFormat: @"%@/photos/list?sortBy=dateUploaded,DESC&pageSize=%i", [standardUserDefaults valueForKey:kTroveboxServer], [self.images count]];
                        
                        [self.uploader loadDataAndSaveEntityUploadDate:[NSDate date]
                                                         shareFacebook:facebook
                                                          shareTwitter:twitter
                                                            permission:permission
                                                                  tags:tags
                                                                albums:albums
                                                                 title:title
                                                                   url:url
                                                              groupUrl:urlString];
                    }
                    
                    // decrease until the first one
                    i--;
                }
            }else{
                // just one photo to share
                [self.uploader loadDataAndSaveEntityUploadDate:[NSDate date]
                                                 shareFacebook:facebook
                                                  shareTwitter:twitter
                                                    permission:permission
                                                          tags:tags
                                                        albums:albums
                                                         title:title
                                                           url:self.image
                                                      groupUrl:nil];
            }
            
            // checkpoint
            if (self.images){
                [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Upload"
                                                                                                    action:@"typeImage"
                                                                                                     label:@"Image from Sync"
                                                                                                     value:nil] build]];
            }else{
                [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Upload"
                                                                                                    action:@"typeImage"
                                                                                                     label:@"Image from Snapshot"
                                                                                                     value:nil] build]];
            }
            
            // wait for 2 seconds to go to main screen
            [NSThread sleepForTimeInterval:4];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // stop loading
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                
                // if it comes form the sync,
                // go back in the navigation
                if (self.images){
                    [self.navigationController popViewControllerAnimated:NO];
                    [(MenuViewController*) SharedAppDelegate.menuController displayHomeScreen];
                }else{
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            });
            
        }@catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:exception.description duration:5000];
                [alert showAlert];
                
                // go to home
                if (self.images){
                    [self.navigationController popViewControllerAnimated:NO];
                    [(MenuViewController*) SharedAppDelegate.menuController displayHomeScreen];
                }else{
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            });
        }
    });
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Preparing";
    
    // next visit to Newest Home does not need update
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDisableUpdateHome object:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error.localizedDescription != nil){
        NSLog(@"Image could not be saved = %@", error.localizedDescription);
    }else{
#ifdef DEVELOPMENT_ENABLED
        NSLog(@"Image saved");
#endif
    }
}

@end

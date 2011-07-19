#import "LauncherController.h"

@implementation LauncherController

- (void)loadView {
    [super loadView];
    
    self.title = @"Open Photo Mobile";
    self.navigationItem.rightBarButtonItem =
    [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                     target:self
                                     action:@selector(openPickerFromButton)] autorelease];

    
    launcherView = [[TTLauncherView alloc] initWithFrame:self.view.bounds];
    launcherView.delegate = self;
    launcherView.pages = [NSArray arrayWithObjects:
                          [NSArray arrayWithObjects:
                           [[[TTLauncherItem alloc] initWithTitle:@"Gallery"
                                                            image:@"bundle://Icon-72.png"
                                                              URL:@"openphoto://gallery" canDelete:NO] autorelease],
                           [[[TTLauncherItem alloc] initWithTitle:@"Website"
                                                           image:@"bundle://Icon-72.png"
                                                              URL:@"http://openphoto.me" canDelete:NO] autorelease],
                           nil],
                          nil];
    
    launcherView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:launcherView];    
}


- (void)launcherView:(TTLauncherView*)launcher didSelectItem:(TTLauncherItem*)item {
    [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:item.URL]];
}

- (void) openPickerFromButton{
    NSLog(@"Get pictures");
}
@end

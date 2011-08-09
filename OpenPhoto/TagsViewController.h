#import <Three20/Three20.h>
#import "MockDataSource.h"
#import "GalleryViewController.h"
#import "WebService.h"

@class MockDataSource;

@interface TagsViewController : TTTableViewController <TTSearchTextFieldDelegate, WebServiceDelegate>{
    WebService* service;
}
@property (nonatomic, retain) WebService* service;
@end


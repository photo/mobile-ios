//
//  TagViewController.h
//  OpenPhoto
//
//  Created by Patrick Santana on 11/08/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"
#import "WebService.h"
#import "GalleryViewController.h"

@interface TagViewController : UITableViewController<WebServiceDelegate>{
    NSMutableArray *tags;
    WebService *service;
    BOOL readOnly;
}

@property (nonatomic, retain) NSMutableArray *tags;
@property (nonatomic, retain) WebService *service;

-(void) setReadOnly;
-(NSArray*) getSelectedTags;
-(NSString *) getSelectedTagsInJsonFormat;

@end

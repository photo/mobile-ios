//
//  UpdateUtilities.h
//  OpenPhoto
//
//  Created by Patrick Santana on 31/10/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthenticationHelper.h"
#import "WebService.h"

@interface UpdateUtilities : NSObject{
    WebService *service;
}
@property (nonatomic, retain) WebService *service;

// singleton
+(UpdateUtilities*) instance;

//methods
- (NSString*) getVersion;
- (BOOL) needsUpdate;
- (void) update;
- (void) updateSystemVersion;

@end

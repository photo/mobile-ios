//
//  UpdateUtilities.h
//  OpenPhoto
//
//  Created by Patrick Santana on 31/10/11.
//  Copyright (c) 2011 OpenPhoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthenticationHelper.h"

@interface UpdateUtilities : NSObject{
    
}

// singleton
+(UpdateUtilities*) instance;

//methods
- (NSString*) getVersion;
- (BOOL) needsUpdate;
- (void) update;

@end

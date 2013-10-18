//
//  Permission.m
//  Trovebox
//
//  Created by Patrick Santana on 15/10/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "Permission.h"

@implementation Permission

#define kPermissionC           @"permission_value_c"
#define kPermissionR           @"permission_value_r"
#define kPermissionU           @"permission_value_u"
#define kPermissionD           @"permission_value_d"

@synthesize c=_c, r=_r, u=_u, d=_d;

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.c forKey:kPermissionC];
    [encoder encodeObject:self.r forKey:kPermissionR];
    [encoder encodeObject:self.u forKey:kPermissionU];
    [encoder encodeObject:self.d forKey:kPermissionD];
}

- (id)initWithCoder:(NSCoder *)decoder {
    // create a object and set all details
    self = [[Permission alloc] init];
    
    if (self != nil){
        self.c = [decoder decodeObjectForKey:kPermissionC];
        self.r = [decoder decodeObjectForKey:kPermissionR];
        self.u = [decoder decodeObjectForKey:kPermissionU];
        self.d = [decoder decodeObjectForKey:kPermissionD];
    }
    
    // return the object saved
    return self;
}

@end

//
//  Friend.m
//  Trovebox
//
//  Created by Patrick Santana on 30/04/14.
//  Copyright (c) 2014 Trovebox. All rights reserved.
//

#import "Friend.h"

@implementation Friend

@synthesize host=_host, name=_name, userName=_userName, photoUrl=_photoUrl;

- (id) initWithHost:(NSString*) host name:(NSString*) name userName:(NSString*) userName photoUrl:(NSString*) photoUrl
{
    self = [super init];
    if (self) {
        _host = host;
        _name=name;
        _userName = userName;
        _photoUrl=photoUrl;
    }
    return self;
}
@end

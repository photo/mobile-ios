//
//  JobUploaderDelegate.m
//  OpenPhoto
//
//  Created by Patrick Santana on 05/07/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "JobUploaderDelegate.h"

@interface JobUploaderDelegate()

@property (nonatomic, retain) NSNumber *totalSize;
@property (nonatomic, retain) NSNumber *alreadySent;
@property (nonatomic, retain) TimelinePhotos* photoDelegate;

@end


@implementation JobUploaderDelegate
@synthesize totalSize=_totalSize, alreadySent=_alreadySent, photoDelegate = _photoDelegate;

- (id) initWithPhoto:(TimelinePhotos*) photo size:(NSUInteger) bytes;
{
    self = [super init];
    if (self) {
        self.photoDelegate = photo;
        self.totalSize = [NSNumber numberWithUnsignedInteger:bytes];
        self.alreadySent = [NSNumber numberWithInt:0];
    }
    return self;
}

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    self.alreadySent = [NSNumber numberWithUnsignedLongLong:[self.alreadySent longLongValue] + bytes ];
    
    // update the object.
    // TODO: we should not update all the time, too heavy. 
    dispatch_async(dispatch_get_main_queue(), ^{
        self.photoDelegate.photoUploadProgress =[ NSNumber numberWithFloat:[self.alreadySent floatValue]/[self.totalSize floatValue]];
    });
    
}

@end

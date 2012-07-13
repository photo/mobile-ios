//
//  JobUploaderDelegate.m
//  OpenPhoto
//
//  Created by Patrick Santana on 05/07/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "JobUploaderDelegate.h"

@interface JobUploaderDelegate()
{
    BOOL needsUpdate;
}

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
        needsUpdate = YES;
    }
    return self;
}

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    self.alreadySent = [NSNumber numberWithUnsignedLongLong:[self.alreadySent longLongValue] + bytes ];
    
    // update the object.
    // let's update the data only in 50% of the case. 
    // trying to avoid less updates on the database
    if (needsUpdate){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoDelegate.photoUploadProgress =[ NSNumber numberWithFloat:[self.alreadySent floatValue]/[self.totalSize floatValue]];
        });
        needsUpdate = NO;
    }else{
        needsUpdate = YES;
    }
    
}

@end

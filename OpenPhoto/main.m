//
//  main.m
//  OpenPhoto
//
//  Created by Patrick Santana on 25/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"OpenPhotoAppDelegate");
    [pool release];
    return retVal;
}

//
//  DateUtilities.m
//  Trovebox
//
//  Created by Patrick Santana on 28/02/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "DateUtilities.h"

@implementation DateUtilities

+ (int)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2 {
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
    return [components day]+1;
}

@end

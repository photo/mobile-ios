//
//  SKProduct+LocalizedPrice.m
//  Trovebox
//
//  Created by Patrick Santana on 25/02/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "SKProduct+LocalizedPrice.h"
#import <StoreKit/StoreKit.h>

@implementation SKProduct (LocalizedPrice)

- (NSString *)localizedPrice
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    return [numberFormatter stringFromNumber:self.price];
}

@end

//
//  SKProduct+LocalizedPrice.h
//  Trovebox
//
//  Created by Patrick Santana on 25/02/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end

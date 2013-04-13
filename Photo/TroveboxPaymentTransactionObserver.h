//
//  TroveboxPaymentTransactionObserver.h
//  Trovebox
//
//  Created by Patrick Santana on 08/02/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

//for payment
#import <StoreKit/StoreKit.h>
#import "AuthenticationService.h"

#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"
#define kInAppPurchaseProUpgradeProductId @"SUBS_TROVEBOX_MONTH"

@interface TroveboxPaymentTransactionObserver : NSObject <SKPaymentTransactionObserver>

+ (TroveboxPaymentTransactionObserver*) troveboxPaymentTransactionObserver;

@end

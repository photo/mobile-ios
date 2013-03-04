//
//  TroveboxSubscription.h
//  Trovebox
//
//  Created by Patrick Santana on 20/02/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

//for payment
#import <StoreKit/StoreKit.h>
#import "TroveboxPaymentTransactionObserver.h"

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"

@interface TroveboxSubscription : NSObject <SKProductsRequestDelegate>
{
    SKProductsRequest *productsRequest;
}

@property (nonatomic, retain) SKProduct *proUpgradeProduct;

+ (TroveboxSubscription*) createTroveboxSubscription;

// init the details for the suscription
- (void) requestProUpgradeProductData;
- (SKProduct*) product;

@end

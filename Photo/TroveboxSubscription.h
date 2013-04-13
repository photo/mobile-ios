//
//  TroveboxSubscription.h
//  Trovebox
//
//  Created by Patrick Santana on 20/02/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

//for payment
#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"

@interface TroveboxSubscription : NSObject <SKProductsRequestDelegate>
{
    SKProductsRequest *productsRequest;
}

@property (nonatomic, retain) SKProduct *proUpgradeProduct;

+ (TroveboxSubscription*) troveboxSubscription;

// init the details for the suscription
- (void) requestProUpgradeProductData;
- (SKProduct*) product;

@end

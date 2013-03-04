//
//  TroveboxSubscription.m
//  Trovebox
//
//  Created by Patrick Santana on 20/02/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "TroveboxSubscription.h"

@implementation TroveboxSubscription

@synthesize proUpgradeProduct=_proUpgradeProduct;

+ (TroveboxSubscription*) createTroveboxSubscription
{
    static dispatch_once_t pred;
    static TroveboxSubscription *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[TroveboxSubscription alloc] init];
        
    });
    
    return shared;
}

- (void) requestProUpgradeProductData
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Init subscriptions details");
#endif
    
    NSSet *productIdentifiers = [NSSet setWithObject:kInAppPurchaseProUpgradeProductId];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:
                                 productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
}
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    self.proUpgradeProduct = [products count] == 1 ? [products lastObject] : nil;
#ifdef DEVELOPMENT_ENABLED
    if (self.proUpgradeProduct)
    {
        NSLog(@"Product title: %@" , self.proUpgradeProduct.localizedTitle);
        NSLog(@"Product description: %@" , self.proUpgradeProduct.localizedDescription);
        NSLog(@"Product price: %@" , self.proUpgradeProduct.price);
        NSLog(@"Product id: %@" , self.proUpgradeProduct.productIdentifier);
    }
#endif
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}

- (SKProduct*) product{
    return self.proUpgradeProduct;
}

-(void)requestDidFinish:(SKRequest *)request
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Request did finish = %@",request);
#endif
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Failed to connect with error: %@", [error localizedDescription]);
#endif
}

@end

//
//  TroveboxSubscription.m
//  Trovebox
//
//  Created by Patrick Santana on 20/02/13.
//  Copyright 2013 Trovebox
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TroveboxSubscription.h"

@implementation TroveboxSubscription

@synthesize proUpgradeProduct=_proUpgradeProduct;

+ (TroveboxSubscription*) troveboxSubscription
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

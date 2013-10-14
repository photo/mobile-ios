//
//  TroveboxPaymentTransactionObserver.h
//  Trovebox
//
//  Created by Patrick Santana on 08/02/13.
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

//for payment
#import <StoreKit/StoreKit.h>
#import "AuthenticationService.h"

#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"
#define kInAppPurchaseProUpgradeProductId @"SUBS_TROVEBOX_MONTH"

@interface TroveboxPaymentTransactionObserver : NSObject <SKPaymentTransactionObserver>

+ (TroveboxPaymentTransactionObserver*) troveboxPaymentTransactionObserver;

@end

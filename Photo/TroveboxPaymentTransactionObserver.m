//
//  TroveboxPaymentTransactionObserver.m
//  Trovebox
//
//  Created by Patrick Santana on 08/02/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "TroveboxPaymentTransactionObserver.h"

@implementation TroveboxPaymentTransactionObserver

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"recordTransaction");
#endif
    
    if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProUpgradeProductId])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:kProfileAccountProReceipt];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // send the receipt to the
        // do it in a queue
        dispatch_queue_t send_receipt_server = dispatch_queue_create("send_receipt_server", NULL);
        dispatch_async(send_receipt_server, ^{
            
            @try{
                [AuthenticationService sendToServerReceipt:transaction.transactionReceipt forUser:[SharedAppDelegate userEmail]];
            }@catch (NSException* exception) {
                NSLog(@"Error sending receipt to server %@", [exception description]);
            }
        });
        dispatch_release(send_receipt_server);
    }
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"provideContent");
#endif
    
    if ([productId isEqualToString:kInAppPurchaseProUpgradeProductId])
    {
        // enable the pro features after 3 seconds
        [NSThread sleepForTimeInterval:3];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationProfileRefresh object:nil userInfo:nil];
    }
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"finishTransaction");
#endif
    
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"completeTransaction");
#endif
    
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"restoreTransaction");
#endif
    
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"failedTransaction");
#endif
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"paymentQueue");
#endif
    
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

@end

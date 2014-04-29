//
//  PrivateAccountLoginService.m
//  Trovebox
//
//  Created by Patrick Santana on 06/03/12.
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


#import "PrivateAuthenticationService.h"
#import "SHA1.h"
#import "ASIFormDataRequest.h"
#import "SBJSON.h"


@interface PrivateAuthenticationService ()

// private methods
+ (NSArray *) parseResponse:(NSDictionary *) responseResult;
+ (Account *) parseResponseCreateAccount:(NSDictionary *) responseResult;

+ (NSArray *) sendRequest:(NSDictionary*) parameters input:(NSString *) input signature:(NSString*) signature url:(NSString *)url;
+ (Account *) sendRequestCreateAccount:(NSDictionary*) parameters input:(NSString *) input signature:(NSString*) signature url:(NSString *)url;

+ (NSDictionary *) sendRawRequest:(NSDictionary*) parameters input:(NSString *) input signature:(NSString*) signature url:(NSString *)url;

@end

/*
 * Secrets
 */
NSString * const kAccountSecret = @"576fdb23e9c45ee45e0ce8a6b011abda";
NSString * const kAccountKeyKeyValue = @"5251bca7a0";

/*
 * URL for requests
 */
// login account
NSString * const kLoginAccountUrl= @"https://trovebox.com/user/v2/login.json";
// reset password
NSString * const kResetPasswordAccountUrl= @"https://trovebox.com/user/password/reset.json";
// payment iTunes
NSString * const kPaymentSubscriptionUrl= @"https://trovebox.com/user/payment.json";


/*
 * Parameters
 */
NSString * const kNewAccountKeyUser = @"username";
NSString * const kNewAccountKeyKey = @"key";
NSString * const kNewAccountKeySignature = @"signature";
NSString * const kNewAccountKeyName = @"name";
NSString * const kNewAccountKeyPassword = @"password";

NSString * const kAccountKeyEmail = @"email";
NSString * const kAccountKeyNonce = @"nonce";
NSString * const kReceiptKeyName = @"data";


@implementation PrivateAuthenticationService

+ (NSArray *) signIn:(NSString*) email password:(NSString*) pwd
{
    // prepare the parameters that should be ORDERED by key
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:kAccountKeyKeyValue forKey:kNewAccountKeyKey];
    [parameters setValue:email forKey:kAccountKeyEmail];
    [parameters setValue:pwd forKey:kNewAccountKeyPassword];
    [parameters setValue:[NSString stringWithFormat:@"%ld", time(NULL)] forKey:kAccountKeyNonce];
    [parameters setValue:[[UIDevice currentDevice] name] forKey:kNewAccountKeyName];
    
    NSArray *keys = [parameters allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    // concat the parameters
    // signature
    NSMutableString *input = [NSMutableString string];
    
    for (NSString *key in sortedKeys) {
        NSString *value = [parameters objectForKey:key];
        [input appendString:[[NSString alloc]initWithFormat:@"%@.%@.",key,value]];
    }
    
    [input appendString:kAccountSecret];
    
    // create the signature
    NSString *signature = [SHA1 sha1:input];
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Sign In");
    NSLog(@"Parameters = %@",parameters);
    NSLog(@"Input = %@",input);
    NSLog(@"Signature = %@",signature);
    NSLog(@"url = %@",kLoginAccountUrl);
#endif
    
    // send request
    return [PrivateAuthenticationService sendRequest:parameters input:input signature:signature url:kLoginAccountUrl];
}


+ (NSString *) recoverPassword:(NSString *) email{
    // prepare the parameters that should be ORDERED by key
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSString stringWithFormat:@"%ld", time(NULL)] forKey:kAccountKeyNonce];
    [parameters setValue:kAccountKeyKeyValue forKey:kNewAccountKeyKey];
    [parameters setValue:email forKey:kAccountKeyEmail];
    
    NSArray *keys = [parameters allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    // concat the parameters
    // signature
    NSMutableString *input = [NSMutableString string];
    
    for (NSString *key in sortedKeys) {
        NSString *value = [parameters objectForKey:key];
        [input appendString:[[NSString alloc]initWithFormat:@"%@.%@.",key,value]];
    }
    
    [input appendString:kAccountSecret];
    
    // create the signature
    NSString *signature = [SHA1 sha1:input];
    
    // send request
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kResetPasswordAccountUrl]];
    for (NSString *key in parameters) {
        [request setPostValue:[parameters objectForKey:key] forKey:key];
    }
    [request setPostValue:signature forKey:kNewAccountKeySignature];
    [request startSynchronous];
    
    //
    // Parse answer
    //
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Response = %@",[request responseString]);
    NSLog(@"Code = %i", [request responseStatusCode]);
#endif
    
    SBJsonParser *parser =[[SBJsonParser alloc] init];
    NSDictionary *response = [parser objectWithString:[request responseString]];    NSInteger code =[ [response objectForKey:@"code"] integerValue];
    
    if (code == 200 || code == 404){
        return [response valueForKey:@"message"];
    }else{
        // unkown error, throw exception
        NSString *message= [response valueForKey:@"message"];
        NSException *exception = [NSException exceptionWithName: NSLocalizedString(@"Couldn't execute request",@"Authentication")
                                                         reason: message
                                                       userInfo: nil];
        @throw exception;
    }
    
}

+ (void) sendToServerReceipt:(NSData *) receipt forUser:(NSString *) email
{
    // prepare the parameters that should be ORDERED by key
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSString stringWithFormat:@"%ld", time(NULL)] forKey:kAccountKeyNonce];
    [parameters setValue:kAccountKeyKeyValue forKey:kNewAccountKeyKey];
    [parameters setValue:email forKey:kAccountKeyEmail];
    [parameters setValue:[TransformationUtilities base64forData:receipt] forKey:kReceiptKeyName];
    
    NSArray *keys = [parameters allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    // concat the parameters
    // signature
    NSMutableString *input = [NSMutableString string];
    
    for (NSString *key in sortedKeys) {
        NSString *value = [parameters objectForKey:key];
        [input appendString:[[NSString alloc]initWithFormat:@"%@.%@.",key,value]];
    }
    
    [input appendString:kAccountSecret];
    
    // create the signature
    NSString *signature = [SHA1 sha1:input];
    
    // send request
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kPaymentSubscriptionUrl]];
    for (NSString *key in parameters) {
        [request setPostValue:[parameters objectForKey:key] forKey:key];
    }
    [request setPostValue:signature forKey:kNewAccountKeySignature];
    [request startSynchronous];
    
    //
    // Parse answer
    //
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Response = %@",[request responseString]);
    NSLog(@"Code = %i", [request responseStatusCode]);
#endif
    
    SBJsonParser *parser =[[SBJsonParser alloc] init];
    NSDictionary *response = [parser objectWithString:[request responseString]];
    NSInteger code =[ [response objectForKey:@"code"] integerValue];
    
    if (code != 200 && code != 404){
        NSLog(@"Error from server to send receipt. Message = %@", [response valueForKey:@"message"]);
    }
}

/////
/////
///// Private methods
/////
/////
+ (NSArray *) sendRequest:(NSDictionary*) parameters input:(NSString *) input signature:(NSString*) signature url:(NSString *)url
{
    // send raw request
    NSDictionary *responseResult = [PrivateAuthenticationService sendRawRequest:parameters input:input signature:signature url:url];
    return [PrivateAuthenticationService parseResponse:responseResult];
    
}

+ (Account *) sendRequestCreateAccount:(NSDictionary*) parameters input:(NSString *) input signature:(NSString*) signature url:(NSString *)url
{
    // send raw request
    NSDictionary *responseResult = [PrivateAuthenticationService sendRawRequest:parameters input:input signature:signature url:url];
    return [PrivateAuthenticationService parseResponseCreateAccount:responseResult];
}

+ (Account *) parseResponseCreateAccount:(NSDictionary *) responseResult;
{
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Response = %@",responseResult);
#endif
    
    Account *account = [[Account alloc] init];
    
    // account details
    account.clientToken= [responseResult objectForKey:@"id"];
    account.clientSecret= [responseResult objectForKey:@"clientSecret"];
    account.userToken= [responseResult objectForKey:@"userToken"];
    account.userSecret= [responseResult objectForKey:@"userSecret"];
    account.email=[responseResult objectForKey:@"owner"];
    account.host= [NSString stringWithFormat: @"http://%@",[responseResult objectForKey:@"host"]];
    account.type=[responseResult objectForKey:@"_type"];
    
    // profile
    NSDictionary *profileJson = [responseResult objectForKey:@"profile"];
    
    Profile *profile = [[Profile alloc] init];
    profile.paid=[[profileJson objectForKey:@"paid"] boolValue];
    profile.name=[profileJson objectForKey:@"name"];
    profile.photoUrl=[profileJson objectForKey:@"photoUrl"];
    
    // limits
    NSDictionary *limits = [profileJson objectForKey:@"limit"];
    profile.limitRemaining=[limits objectForKey:@"remaining"];
    profile.limitAllowed=[limits objectForKey:@"allowed"];
    
    // counts
    NSDictionary *counts = [profileJson objectForKey:@"counts"];
    profile.photos=[counts objectForKey:@"photos"];
    profile.albums=[counts objectForKey:@"albums"];
    profile.tags=[counts objectForKey:@"tags"];
    profile.storage=[counts objectForKey:@"storage_str"];
    
    account.profile = profile;
    
    // permission
    Permission *permission = [[Permission alloc] init];
    NSDictionary *permissionJson = [profileJson objectForKey:@"permission"];
    permission.c=[permissionJson objectForKey:@"C"];
    permission.r=[permissionJson objectForKey:@"R"];
    permission.u=[permissionJson objectForKey:@"U"];
    permission.d=[permissionJson objectForKey:@"D"];
    account.permission = permission;
    
    return account;
}

+ (NSArray *) parseResponse:(NSDictionary *) responseResult;
{
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Response = %@",responseResult);
#endif
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if ([responseResult class] != [NSNull class]) {
        
        // do a loop in all the user in the response
        for (NSDictionary *user in responseResult){
            Account *account = [self parseResponseCreateAccount:user];
            [array addObject:account];
        }
    }
    
    return array;
}

+ (NSDictionary *) sendRawRequest:(NSDictionary*) parameters input:(NSString *) input signature:(NSString*) signature url:(NSString *)url
{
    // send request
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    
    // incresead time out because with the new login it takes longer.
    [request setTimeOutSeconds:60];
    
    for (NSString *key in parameters) {
        [request setPostValue:[parameters objectForKey:key] forKey:key];
    }
    [request setPostValue:signature forKey:kNewAccountKeySignature];
    [request startSynchronous];
    
    //
    // parse answer
    //
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Request = %@",[request responseString]);
#endif
    
    SBJsonParser *parser =[[SBJsonParser alloc] init];
    NSDictionary *response = [parser objectWithString:[request responseString]];
    NSInteger code =[ [response objectForKey:@"code"] integerValue];
    // if error
    if (code!=200){
        NSString *message= [response valueForKey:@"message"];
        NSException *exception = [NSException exceptionWithName: @"Couldn't execute request"
                                                         reason: message
                                                       userInfo: nil];
        @throw exception;
    }
    
    // get the result from the answer and get all details for the user
    return [response objectForKey:@"result"] ;
}

@end

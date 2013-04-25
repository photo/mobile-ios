/* Copyright (c) 2011 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

// This class provides a way to make easy asynchronous requests to Google for
// conversion pings. Use the code as follows:
//   [GoogleConversionPing pingWithConversionId:@"your id here"
//                                        label:@"your label here"
//                                        value:@"your app's price here"
//                                 isRepeatable:YES/NO];
// For example, to track downloads of your app, add the code to your application
// delegate's application:didFinishLaunchingWithOptions: method.
@interface GoogleConversionPing : NSObject

// Reports a conversion to Google.
+ (void)pingWithConversionId:(NSString *)conversionId
                       label:(NSString *)label
                       value:(NSString *)value
                isRepeatable:(BOOL)isRepeatable;

// Returns the Google Conversion SDK version.
+ (NSString *)sdkVersion;

#pragma mark - Deprecated

// UDID has been deprecated and this SDK only uses the IDFA as of version 1.2.0.
// Setting the |idfaOnly| parameter is a no-op.
+ (void)pingWithConversionId:(NSString *)conversionId
                       label:(NSString *)label
                       value:(NSString *)value
                isRepeatable:(BOOL)isRepeatable
                    idfaOnly:(BOOL)idfaOnly;

@end

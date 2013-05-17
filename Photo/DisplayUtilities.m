//
//  DisplayUtilities.m
//  Trovebox
//
//  Created by Patrick Santana on 29/10/12.
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

#import "DisplayUtilities.h"

@implementation DisplayUtilities

+(BOOL) isRetina
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
        return YES;
    }
    
    return NO;
}

+(BOOL) isIPhone
{
    return ![DisplayUtilities isIPad];
}

+(BOOL) isIPad
{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        return YES;
    }
    
    return NO;
}

+ (BOOL) is4InchRetina
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        return YES;
    }
    
    return NO;
}

+(NSString*) getCorrectNibName:(NSString*) nibName
{
    if ( [DisplayUtilities isIPad] ){
        // for now we don't do the ipad
        return nibName;
    }else if ( [DisplayUtilities is4InchRetina]){
        return [[NSString alloc] initWithFormat:@"%@%@",nibName,@"5"];
    }
    
    // return default
    return nibName;   
}

@end

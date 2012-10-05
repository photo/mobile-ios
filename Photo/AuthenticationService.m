//
//  AuthenticationService.m
//  Photo
//
//  Created by Patrick Santana on 05/10/12.
//  Copyright (c) 2012 Photo Project. All rights reserved.
//

#import "AuthenticationService.h"

@implementation AuthenticationService

-(NSURL*) getOAuthInitialUrl{
    // get the url
    NSString *server = [[NSUserDefaults standardUserDefaults] valueForKey:kOpenPhotoServer];
    NSString *path = @"/v1/oauth/authorize?oauth_callback=photo-test://&name=";
    NSString *appName = [[UIDevice currentDevice] name];
    NSString *fullPath = [[NSString alloc]initWithFormat:@"%@%@%@",server,path,[appName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ;
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"URL for OAuth initialization = %@",fullPath);
#endif
    NSURL *url = [NSURL URLWithString:fullPath];
    
    if (!url){
        NSLog(@"URL is invalid, use the default.");
        return [NSURL URLWithString:[[NSString alloc]initWithFormat:@"%@%@%@",server,path,@"Photo%20App"] ];
    }
    
    return url;
}

-(NSURL*) getOAuthAccessUrl{
    // get the url
    NSString* server = [[NSUserDefaults standardUserDefaults] valueForKey:kOpenPhotoServer];
    NSString* url = [[NSString alloc]initWithFormat:@"%@%@",server,@"/v1/oauth/token/access"] ;
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"URL for OAuth Access = %@",url);
#endif
    
    return [NSURL URLWithString:url];
}

-(NSURL*) getOAuthTestUrl{
    // get the url
    NSString* server = [[NSUserDefaults standardUserDefaults] valueForKey:kOpenPhotoServer];
    NSString* url = [[NSString alloc]initWithFormat:@"%@%@",server,@"/v1/oauth/test"] ;
    
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"URL for OAuth Test = %@",url);
#endif
    
    return [NSURL URLWithString:url];
}

@end
 

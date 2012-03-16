//
//  OpenPhotoTTThumbsViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 29/01/12.
//  Copyright 2012 OpenPhoto
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

#import "OpenPhotoTTThumbsViewController.h"

@interface OpenPhotoTTThumbsViewController()
- (OpenPhotoTTPhotoViewController*)createPhotoViewController;
@end

@implementation OpenPhotoTTThumbsViewController

- (void)loadView {
    [super loadView];
    self.tableView.sectionHeaderHeight = 0;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)thumbsTableViewCell:(TTThumbsTableViewCell*)cell didSelectPhoto:(id<TTPhoto>)photo {
    [_delegate thumbsViewController:self didSelectPhoto:photo];
    
    BOOL shouldNavigate = YES;
    if ([_delegate respondsToSelector:@selector(thumbsViewController:shouldNavigateToPhoto:)]) {
        shouldNavigate = [_delegate thumbsViewController:self shouldNavigateToPhoto:photo];
    }
    
    if (shouldNavigate) {
        NSString* URL = [self URLForPhoto:photo];
        if (URL) {
            TTOpenURLFromView(URL, self.view);
            
        } else {
            OpenPhotoTTPhotoViewController* controller = [self createPhotoViewController];
            controller.centerPhoto = photo;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (OpenPhotoTTPhotoViewController*)createPhotoViewController {
    return [[[OpenPhotoTTPhotoViewController alloc] init] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)URLForPhoto:(id<TTPhoto>)photo {
    if ([photo respondsToSelector:@selector(URLValueWithName:)]) {
        return [photo URLValueWithName:@"OpenPhotoTTPhotoViewController"];
        
    } else {
        return nil;
    }
}

@end

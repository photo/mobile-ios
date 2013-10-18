//
//  Profile.m
//  Trovebox
//
//  Created by Patrick Santana on 15/10/13.
//  Copyright (c) 2013 Trovebox. All rights reserved.
//

#import "Profile.h"

@implementation Profile

#define kPaid           @"profile_paid"
#define kLimitRemaining @"profile_limit_remaining"
#define kLimitAllowed   @"profile_limit_allowed"
#define kName           @"profile_name"
#define kPhotos         @"profile_photos"
#define kAlbums         @"profile_albums"
#define kStorage        @"profile_storage"
#define kPhotoUrl       @"profile_photo_url"
#define kTags           @"profile_tags"

@synthesize paid=_paid, limitRemaining=_limitRemaining, limitAllowed=_limitAllowed, name=_name, photos=_photos, albums=_albums, storage=_storage, photoUrl=_photoUrl, tags=_tags;

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeBool:self.paid forKey:kPaid];
    if (self.limitRemaining)
        [encoder encodeObject:self.limitRemaining forKey:kLimitRemaining];
    if (self.limitAllowed)
        [encoder encodeObject:self.limitAllowed forKey:kLimitAllowed];
    if (self.name)
        [encoder encodeObject:self.name forKey:kName];
    if (self.photos)
        [encoder encodeObject:self.photos forKey:kPhotos];
    if (self.albums)
        [encoder encodeObject:self.albums forKey:kAlbums];
    if(self.storage)
        [encoder encodeObject:self.storage forKey:kStorage];
    if (self.photoUrl)
        [encoder encodeObject:self.photoUrl forKey:kPhotoUrl];
    if (self.tags)
        [encoder encodeObject:self.tags forKey:kTags];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    // create a object and set all details
    self = [[Profile alloc] init];
    if (self != nil){
        self.paid = [decoder decodeBoolForKey:kPaid];
        self.limitRemaining = [decoder decodeObjectForKey:kLimitRemaining];
        self.limitAllowed= [decoder decodeObjectForKey:kLimitAllowed];
        self.name= [decoder decodeObjectForKey:kName];
        self.photos= [decoder decodeObjectForKey:kPhotos];
        self.albums= [decoder decodeObjectForKey:kAlbums];
        self.storage= [decoder decodeObjectForKey:kStorage];
        self.tags= [decoder decodeObjectForKey:kTags];
        self.photoUrl= [decoder decodeObjectForKey:kPhotoUrl];
    }
    
    // return the object saved
    return self;
}

@end

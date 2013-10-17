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
    [encoder encodeObject:self.limitRemaining forKey:kLimitRemaining];
    [encoder encodeObject:self.limitAllowed forKey:kLimitAllowed];
    [encoder encodeObject:self.name forKey:kName];
    [encoder encodeObject:self.photos forKey:kPhotos];
    [encoder encodeObject:self.albums forKey:kAlbums];
    [encoder encodeObject:self.storage forKey:kStorage];
    [encoder encodeObject:self.photoUrl forKey:kPhotoUrl];
    [encoder encodeObject:self.tags forKey:kTags];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    // create a object and set all details
    Profile *profile = [self init];
    
    profile.paid = [decoder decodeBoolForKey:kPaid];
    profile.limitRemaining = [decoder decodeObjectForKey:kLimitRemaining];
    profile.limitAllowed= [decoder decodeObjectForKey:kLimitAllowed];
    profile.name= [decoder decodeObjectForKey:kName];
    profile.photos= [decoder decodeObjectForKey:kPhotos];
    profile.albums= [decoder decodeObjectForKey:kAlbums];
    profile.storage= [decoder decodeObjectForKey:kStorage];
    profile.tags= [decoder decodeObjectForKey:kTags];
    profile.photoUrl= [decoder decodeObjectForKey:kPhotoUrl];
    
    // return the object saved
    
    return profile;
}

@end

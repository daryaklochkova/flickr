//
//  Photo.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 08/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "Photo.h"

@implementation Photo

- (instancetype)initWithDictionary:(NSDictionary *) dictionary{
    self = [super init];
    
    if (self){
        _photoID = [dictionary objectForKey:@"id"];
        _owner = [dictionary objectForKey:@"owner"];
        _secret = [dictionary objectForKey:@"secret"];
        _server = [dictionary objectForKey:@"server"];
        _farm = [dictionary objectForKey:@"farm"];
        _title = [dictionary objectForKey:@"title"];
        _isPublic = [dictionary objectForKey:@"ispublic"];
        _isFriend = [dictionary objectForKey:@"isfriend"];
        _isFamily = [dictionary objectForKey:@"isfamily"];
        _isPrimary = [dictionary objectForKey:@"is_primary"];
        _hasComment = [dictionary objectForKey:@"has_comment"];
        _remoteURL = [self getPhotoURL];
        
        if (self.farm) {
            _name = [self.remoteURL lastPathComponent];
        } else {
            _name = self.photoID;
        }
        
    }
    return self;
}

- (instancetype)initPrimaryPhotoWithDictionary:(NSDictionary *) dictionary{
    self = [super init];
    
    if (self){
        _photoID = [dictionary objectForKey:@"primary_photo_id"];
        _owner = [dictionary objectForKey:@"owner"];
        _secret = [dictionary objectForKey:@"primary_photo_secret"];
        _server = [dictionary objectForKey:@"primary_photo_server"];
        _farm = [dictionary objectForKey:@"primary_photo_farm"];
        _remoteURL = [self getPhotoURL];
        
        if (self.farm) {
            _name = [self.remoteURL lastPathComponent];
        } else {
            _name = self.photoID;
        }
        
    }
    return self;
}

- (NSURL *)getPhotoURL {
    NSString *stringURL = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg", self.farm, self.server, self.photoID, self.secret];
    
    return [NSURL URLWithString:stringURL];
}

@end

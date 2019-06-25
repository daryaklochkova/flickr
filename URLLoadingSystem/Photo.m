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
        _photoID = dictionary[@"id"];
        _owner = dictionary[@"owner"];
        _secret = dictionary[@"secret"];
        _server = dictionary[@"server"];
        _farm = dictionary[@"farm"];
        _title = dictionary[@"title"];
        _isPublic = dictionary[@"ispublic"];
        _isFriend = dictionary[@"isfriend"];
        _isFamily = dictionary[@"isfamily"];
        _isPrimary = dictionary[@"is_primary"];
        _hasComment = dictionary[@"has_comment"];
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
        _photoID = dictionary[@"primary_photo_id"];
        _owner = dictionary[@"owner"];
        _secret = dictionary[@"primary_photo_secret"];
        _server = dictionary[@"primary_photo_server"];
        _farm = dictionary[@"primary_photo_farm"];
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

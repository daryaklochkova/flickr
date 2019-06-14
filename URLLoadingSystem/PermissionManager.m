//
//  PermissionManager.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "PermissionManager.h"
#import "Constants.h"

@implementation PermissionManager

+ (instancetype) defaultManager {
    static dispatch_once_t once = 0;
    static id _sharedObject = nil;
    dispatch_once(&once, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (BOOL)isLoginedUserHasPermissionForEditing:(User *)ownerUser {
    NSString *logdedInUserID = [[NSUserDefaults standardUserDefaults] objectForKey:[LoginedUserID copy]];
    return [ownerUser.userID isEqualToString:logdedInUserID];
}

@end

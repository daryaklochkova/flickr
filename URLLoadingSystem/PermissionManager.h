//
//  PermissionManager.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface PermissionManager : NSObject

+ (instancetype) defaultManager;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;


- (BOOL)isLoginedUserHasPermissionForEditing:(User *)ownerUser;

@end

NS_ASSUME_NONNULL_END

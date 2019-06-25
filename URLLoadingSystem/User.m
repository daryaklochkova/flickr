//
//  User.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 05/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithUserID:(NSString *)userID andName:(NSString *)userName andFolderDirectory:(NSSearchPathDirectory)directory {
    self = [super init];
    if (self) {
        self.userID = userID;
        self.userName = userName;
        self.userFolder = [self createUserFolder:directory];
    }
    return self;
}

- (NSString *)createUserFolder:(NSSearchPathDirectory) baseDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(baseDirectory, NSUserDomainMask, YES);
    
    NSString *directory = paths[0];
    NSString *userDir = [directory stringByAppendingPathComponent:self.userID];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:userDir
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    return userDir;
}

@end

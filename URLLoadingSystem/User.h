//
//  User.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 05/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *userName;

@property (strong, nonatomic) NSString *userFolder;

- (instancetype)initWithUserID:(NSString *)userID andName:(NSString *)userName andFolderDirectory:(NSSearchPathDirectory)directory;

@end

NS_ASSUME_NONNULL_END

//
//  AlertManager.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 18/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlertManager : NSObject

+ (instancetype)defaultManager;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (UIAlertController *)showErrorAlertWithTitle:(NSString *)title andMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END

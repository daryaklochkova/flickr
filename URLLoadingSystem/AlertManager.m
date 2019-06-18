//
//  AlertManager.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 18/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "AlertManager.h"

@implementation AlertManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (UIAlertController *)showErrorAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"OK", nil) 
                             style:UIAlertActionStyleCancel
                             handler:nil];
    
    [alert addAction:action];
    return alert;
}

@end

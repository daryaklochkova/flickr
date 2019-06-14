//
//  SelectableCellProtocol.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 14/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SelectableCellProtocol <NSObject>

@property (assign, nonatomic) BOOL isCellSelected;

- (void)selectItem;

@end

NS_ASSUME_NONNULL_END

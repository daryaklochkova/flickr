//
//  GetPhotoResponseDataHandler.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 16/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GetPhotoResponseDataHandler <NSObject>

- (void)addPhoto:(NSDictionary *)photoAttributes;

@end

NS_ASSUME_NONNULL_END

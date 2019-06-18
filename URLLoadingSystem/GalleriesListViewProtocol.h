//
//  GalleriesListViewProtocol.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 17/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GalleriesListViewProtocol <NSObject>

@property (assign, nonatomic) BOOL needReloadContent;

@end

NS_ASSUME_NONNULL_END

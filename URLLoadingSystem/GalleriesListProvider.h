//
//  GalleriesListProvider.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 22/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GalleriesListProviderProtocol.h"
#import "DataProviderNetwork.h"

NS_ASSUME_NONNULL_BEGIN

@interface GalleriesListProvider : DataProviderNetwork <GalleriesListProviderProtocol>

@end

NS_ASSUME_NONNULL_END

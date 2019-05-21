//
//  DataProvider.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 20/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProviderProtocol.h"
#import "DataProviderNetwork.h"
#import "GetPhotosResponseParser.h"
#import "GetListOfGalleriesResponseParser.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataProvider : DataProviderNetwork <DataProviderProtocol>

@end

NS_ASSUME_NONNULL_END

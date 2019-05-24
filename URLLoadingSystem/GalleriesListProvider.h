//
//  GalleriesListProvider.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 22/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parser.h"
#import "ParserProtocol.h"
#import "DataProviderNetwork.h"
#import "XMLParser.h"
#import "GetListOfGalleriesResponseParser.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GalleriesListProviderProtocol <NSObject>

- (void)getAdditionalGalleriesForUser:(NSString * _Nullable)userID use:(ReturnGalleriesResult _Nullable ) completionHandler;
- (void)getGalleriesForUser:(NSString *)userID use:(ReturnResult) completionHandler;

@end

@interface GalleriesListProvider : DataProviderNetwork <GalleriesListProviderProtocol>

@end

NS_ASSUME_NONNULL_END

//
//  GalleriesListProviderProtocol.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 06/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GalleriesListProviderProtocol <NSObject>

- (void)getAdditionalGalleriesForUser:(NSString * _Nullable)userID use:(ReturnGalleriesResult _Nullable ) completionHandler;
- (void)getGalleriesForUser:(NSString *)userID use:(ReturnResult) completionHandler;

@end


NS_ASSUME_NONNULL_END

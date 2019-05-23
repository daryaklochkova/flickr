//
//  GalleryProviderProtocol.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 17/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetListOfGalleriesResponseParser.h"
#import "DataProviderNetwork.h"


@protocol GalleryProviderProtocol <NSObject>

- (instancetype _Nullable )initWithParser:(id<Parser>_Nullable) parser;


- (void)getGalleriesForUser:(NSString * _Nullable)userID use:(ReturnResult _Nullable ) completionHandler;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ListOfGalleriesProvider : DataProviderNetwork <GalleryProviderProtocol>

@end

NS_ASSUME_NONNULL_END

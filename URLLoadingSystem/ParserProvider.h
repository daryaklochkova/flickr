//
//  ParserProvider.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 27/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParserProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParserProvider : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

+ (instancetype)defaultProvider;

- (id <Parser> _Nullable)getParser;

@end

NS_ASSUME_NONNULL_END

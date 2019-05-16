//
//  Parser.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 16/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"

NS_ASSUME_NONNULL_BEGIN

@protocol Parser <NSObject>

@property (strong, nonatomic) id<ResponseParser> response;

- (void)parse:(NSData *) data;

@end

NS_ASSUME_NONNULL_END

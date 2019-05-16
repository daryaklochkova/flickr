//
//  ResponseParser.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 16/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseDataHandler.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ResponseParser <NSObject>

@property (weak, nonatomic) id<ResponseDataHandler> dataHandler;

- (void)didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict;
- (void)didEndDocument;

@end

NS_ASSUME_NONNULL_END

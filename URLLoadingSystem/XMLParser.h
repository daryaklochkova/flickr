//
//  XMLParser.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 16/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParserProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMLParser : NSObject <Parser, NSXMLParserDelegate>

@end

NS_ASSUME_NONNULL_END

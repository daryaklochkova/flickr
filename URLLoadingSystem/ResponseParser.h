//
//  ResponseParser.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 16/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^ReturnResult)(NSArray * _Nullable result);
typedef void(^ReturnGalleriesResult)(NSArray * _Nullable result);
typedef void(^ReturnPhotosResult)(NSArray * _Nullable result);


NS_ASSUME_NONNULL_BEGIN

@protocol ResponseParser <NSObject>

- (instancetype)initWith:(ReturnResult) completionHandler;

- (void)didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict;
- (void)didEndDocument;


@optional

- (void)didEndElement:(NSString *)elementName;
- (void)foundCharacters:(NSString *)string;

@end

NS_ASSUME_NONNULL_END

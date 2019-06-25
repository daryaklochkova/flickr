//
//  SessionDelegate.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 06/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParserProtocol.h"

typedef void(^successDataTaskBlock)(NSData * _Nullable responseData);
typedef void(^successDownloadTaskBlock)(NSURL * _Nullable location);
typedef void(^failBlock)(NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface NetworkManager : NSObject <NSURLSessionDelegate>

@property (strong, nonatomic) NSURLSession *defaultSession;

+ (instancetype) defaultManager;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;


- (void)createConnection;
- (NSURLSessionTask *)fetchData:(NSURLRequest *) request
                parseResponceWith:(id<Parser>)parser
                using:(successDataTaskBlock) succcessBlock
                and:(failBlock) failBlock;

- (NSURLSessionTask *)downloadData:(NSURLRequest *) request
                using:(successDownloadTaskBlock) successBlock
                and:(failBlock) failBlock;

- (NSURLRequest *)createRequestWithDictionary:(NSDictionary<NSString *, NSString *> *)requestFields;

- (void)cancelDownloadTasksWithUrl:(NSURL *)url;
- (void)cancelDataTasksWithUrl:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END

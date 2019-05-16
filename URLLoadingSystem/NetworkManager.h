//
//  SessionDelegate.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 06/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SessionDataTaskCallBack)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);
typedef void(^SessionDownloadTaskCallBack)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error);



NS_ASSUME_NONNULL_BEGIN

@interface NetworkManager : NSObject <NSURLSessionDelegate>

@property (strong, nonatomic) NSURLSession *defaultSession;

+ (instancetype) defaultNetworkManager;

- (void)createConnection;
- (void)fetchDataFromURL:(NSURL *) url using:(SessionDataTaskCallBack) completionHandler;
- (void) downloadData:(NSURL *) url using:(SessionDownloadTaskCallBack) completionHandler;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END

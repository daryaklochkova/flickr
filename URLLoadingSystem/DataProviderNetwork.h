//
//  DataProviderNetwork.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 17/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkManager.h"
#import "ParserProtocol.h"
#import "Photo.h"


NS_ASSUME_NONNULL_BEGIN

extern const NSNotificationName dataFetchError;
extern const NSString *dataFetchErrorKey;

@interface DataProviderNetwork : NSObject

@property (strong, nonatomic) id<Parser> parser;
@property (strong, nonatomic) NSString *continuation;

- (void)sendRequest:(NSDictionary *) requestFields;
- (void)cancelTasksByURL:(NSURL *) url;
- (void)getFileFrom:(NSURL *) remoteURL saveIn:(NSURL *) localFileURL sucsessNotification:(NSNotification *) notification;

- (ReturnResultWithContinuation)createReturnResultWithContinuationWith:(ReturnResult)returnResultBlock;
- (BOOL)continuationExist;
@end

NS_ASSUME_NONNULL_END

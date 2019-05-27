//
//  GalleriesListProvider.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 22/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GalleriesListProvider.h"
#include "ParserProvider.h"

@interface GalleriesListProvider()
@end


@implementation GalleriesListProvider

- (instancetype)init{
    self = [super init];
    
    if (self){
        self.parser = [[ParserProvider defaultProvider] getParser];
    }
    
    return self;
}


- (NSDictionary *)GetRequestFields:(NSString *)userID {
    
    NSDictionary *requestFields = @{
                                    methodArgumentName:       getGalleriesListMethod,
                                    formatArgumentName:       [self.parser getStringFormatType],
                                    userIDArgumentName:       userID,
                                    continuationArgumentName: self.continuation,
                                    shortLimitArgumentName:   @"1",
                                    perPageArgumentName:      @"10"
                                    };
    
    return requestFields;
}


- (void)getGalleriesForUser:(NSString *)userID use:(ReturnResult) completionHandler{
    self.continuation = [continuationStartValue copy];
    [self getAdditionalGalleriesForUser:userID use:completionHandler];
}

- (void)getAdditionalGalleriesForUser:(NSString *)userID use:(ReturnResult) completionHandler{
    if ([self continuationExist]){
        ReturnResultWithContinuation returnBlock = [self createReturnResultWithContinuationWith:completionHandler];
        self.parser.responseParser = [[GetListOfGalleriesResponseParser alloc] initWith:returnBlock];
        [self sendRequest:[self GetRequestFields:userID]];
    }
}

@end

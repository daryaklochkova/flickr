//
//  GalleriesListProvider.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 22/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GalleriesListProvider.h"


@implementation GalleriesListProvider

- (instancetype)init{
    self = [super init];
    
    if (self){
        self.parser = [[XMLParser alloc] init];
    }
    
    return self;
}


- (NSDictionary *)GetRequestFields:(NSString *)userID {
    
    NSDictionary *requestFields = @{
                                    @"method":          @"flickr.galleries.getList",
                                    @"format":          [self.parser getStringFormatType],
                                    @"user_id":         userID,
                                    @"continuation":    @"0",
                                    @"short_limit":     @"1",
                                    @"per_page":        @"1",
                                    @"page":            @"10"
                                    };
    
    return requestFields;
}


- (void)getGalleriesForUser:(NSString *)userID use:(ReturnResult) completionHandler{
    self.parser.responseParser = [[GetListOfGalleriesResponseParser alloc] initWith:completionHandler];
    [self sendRequest:[self GetRequestFields:userID]];
}

@end

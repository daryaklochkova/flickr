//
//  GetPhotosResponce.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 16/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GetPhotosResponseParser.h"
#import "Photo.h"

@interface GetPhotosResponseParser()

@property (strong, nonatomic) NSMutableArray<Photo *> *photos;
@property (strong, nonatomic) ReturnResultWithContinuation completionHandler;

@end

@implementation GetPhotosResponseParser

@synthesize continuation;

- (nonnull instancetype)initWith:(nonnull ReturnResultWithContinuation)completionHandler {
    self = [super init];
    
    if(self){
        self.completionHandler = completionHandler;
        self.photos = [NSMutableArray array];
    }
    
    return self;
}

- (void)didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict{
    
    if ([elementName isEqualToString:@"photos"]){
        self.continuation = [attributeDict objectForKey:@"continuation"];
    }
    
    if ([elementName isEqualToString:@"photo"]){
        Photo *photo = [[Photo alloc] initWithDictionary:attributeDict];
        [self.photos addObject:photo];
    }
}

- (void)didEndDocument{
    if (!self.continuation){
        self.continuation = [continuationEndValue copy];
    }
    
    self.completionHandler(self.photos, self.continuation);
}

@end

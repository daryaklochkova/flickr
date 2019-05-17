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
@property (strong, nonatomic) ReturnResult completionHandler;

@end

@implementation GetPhotosResponseParser

- (void)didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict{
    if ([elementName isEqualToString:@"photo"]){
        Photo *photo = [[Photo alloc] initWithDictionary:attributeDict];
        [self.photos addObject:photo];
    }
}

- (void)didEndDocument {
    self.completionHandler(self.photos);
}

- (nonnull instancetype)initWith:(nonnull ReturnResult)completionHandler {
    self = [super init];
    
    if(self){
        self.completionHandler = completionHandler;
        self.photos = [NSMutableArray array];
    }
    
    return self;
}


@end

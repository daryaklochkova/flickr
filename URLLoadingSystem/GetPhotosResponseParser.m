//
//  GetPhotosResponce.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 16/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GetPhotosResponseParser.h"

@implementation GetPhotosResponseParser

- (void)didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict{
    if ([elementName isEqualToString:@"photo"]){
        if ([self.dataHandler conformsToProtocol:@protocol(GetPhotoResponseDataHandler)]){
            id <GetPhotoResponseDataHandler> getPhotoResponseDataHandler = (id <GetPhotoResponseDataHandler>)self.dataHandler;
            [getPhotoResponseDataHandler addPhoto:attributeDict];
        }
    }
}

- (void)didEndDocument {
    [self.dataHandler allElementsParsed];
}



@synthesize dataHandler;

@end

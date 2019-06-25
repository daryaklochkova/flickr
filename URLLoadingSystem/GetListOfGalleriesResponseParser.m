//
//  GetListOfGalleriesResponceParser.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GetListOfGalleriesResponseParser.h"

@interface GetListOfGalleriesResponseParser()

@property (strong, nonatomic) NSMutableArray<NSMutableDictionary *> *dictionaries;

@property (strong, nonatomic) NSString *currentElement;
@property (strong, nonatomic) NSMutableDictionary *currentGalleryDictionary;

@property (strong, nonatomic) ReturnResultWithContinuation completionHandler;
@end

@implementation GetListOfGalleriesResponseParser

@synthesize continuation;

- (instancetype)initWith:(ReturnResultWithContinuation) completionHandler {
    self = [super init];
    
    if (self){
        self.completionHandler = completionHandler;
        self.dictionaries = [NSMutableArray array];
    }
    
    return self;
}

- (void)foundCharacters:(NSString *)string {
    if ([self.currentElement isEqualToString:@"title"]) {
        NSString *title = self.currentGalleryDictionary[@"title"];
        if (!title) {
            title = [NSString string];
        }
        
        NSString *tmpString = [title stringByAppendingString:string];
        [self.currentGalleryDictionary setValue:tmpString forKey:@"title"];
    }
    
    if ([self.currentElement isEqualToString:@"description"]) {
        NSString *description = self.currentGalleryDictionary[@"description"];
        if (!description) {
            description = [NSString string];
        }
        NSString *tmpString = [description stringByAppendingString:string];
        [self.currentGalleryDictionary setValue:tmpString forKey:@"description"];
    }
}

- (void)didEndElement:(NSString *)elementName{
    self.currentElement = @"";
}

- (void)didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict{
    
    if ([elementName isEqualToString:@"galleries"]){
        self.continuation = attributeDict[@"continuation"];
        
        NSDictionary *galleries = attributeDict[@"galleries"];
        if (galleries) {
            self.continuation = galleries[@"continuation"];
        }
    }
    
    if ([elementName isEqualToString:@"gallery"]) {
        self.currentGalleryDictionary = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
        [self.dictionaries addObject:self.currentGalleryDictionary];
    }
    
    self.currentElement = elementName;
}

- (void)didEndDocument {
    if (!self.continuation){
        self.continuation = [continuationEndValue copy];
    }
    self.completionHandler(self.dictionaries, self.continuation);
}

@end

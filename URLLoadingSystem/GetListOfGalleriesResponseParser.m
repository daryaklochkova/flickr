//
//  GetListOfGalleriesResponceParser.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GetListOfGalleriesResponseParser.h"
#import "Gallery.h"

@interface GetListOfGalleriesResponseParser()

@property (strong, nonatomic) NSMutableArray *galleries;

@property (strong, nonatomic) NSString *currentElement;
@property (strong, nonatomic) Gallery *currentGallery;

@property (strong, nonatomic) ReturnResultWithContinuation completionHandler;
@end

@implementation GetListOfGalleriesResponseParser

@synthesize continuation;

- (instancetype)initWith:(ReturnResultWithContinuation) completionHandler;{
    self = [super init];
    
    if (self){
        self.completionHandler = completionHandler;
        self.galleries = [NSMutableArray array];
    }
    
    return self;
}

- (void)foundCharacters:(NSString *)string{
    if ([self.currentElement isEqualToString:@"title"]){
        NSString *tmpString = [self.currentGallery.title stringByAppendingString:string];
        self.currentGallery.title = tmpString;
    }
}

- (void)didEndElement:(NSString *)elementName{
    self.currentElement = @"";
}

- (void)didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict{
    
    if ([elementName isEqualToString:@"galleries"]){
        self.continuation = [attributeDict objectForKey:@"continuation"];
    }
    
    if ([elementName isEqualToString:@"gallery"]){
        self.currentGallery = [[Gallery alloc] initWithGalleryID:[attributeDict objectForKey:@"gallery_id"]];
        self.currentGallery.primaryPhoto = [[Photo alloc] initPrimaryPhotoWithDictionary:attributeDict];
        [self.galleries addObject:self.currentGallery];
    }
    
    self.currentElement = elementName;
}

- (void)didEndDocument{
    if (!self.continuation){
        self.continuation = [continuationEndValue copy];
    }
    self.completionHandler(self.galleries, self.continuation);
}

@end

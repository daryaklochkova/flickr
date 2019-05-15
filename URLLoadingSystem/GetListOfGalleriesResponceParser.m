//
//  GetListOfGalleriesResponceParser.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GetListOfGalleriesResponceParser.h"

NSNotificationName const ListOfGalleriesRecieved = @"ListOfGalleriesIsReciewed";

@implementation GetListOfGalleriesResponceParser

- (instancetype)initWithListOfGalleries:(ListOfGalleries *)listOfGalleries{
    self = [super init];
    
    if (self){
        self.listOfGalleries = listOfGalleries;
    }
    
    return self;
}

#pragma mark - NSXMLParser Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"gallery"]){
        self.currentGallery = [[Gallery alloc] initWithGalleryID:[attributeDict objectForKey:@"gallery_id"]];
        self.currentGallery.primaryPhoto = [[Photo alloc] initPrimaryPhotoWithDictionary:attributeDict];
        [self.listOfGalleries.galleries addObject:self.currentGallery];
    }
    
    if ([elementName isEqualToString:@"title"]){
        self.currentElement = elementName;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if ([self.currentElement isEqualToString:@"title"]){
        NSString *tmpString = [self.currentGallery.title stringByAppendingString:string];
        self.currentGallery.title = tmpString;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName{
    self.currentElement = @"";
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
    dispatch_async(dispatch_get_main_queue(), ^{
         [[NSNotificationCenter defaultCenter] postNotificationName:ListOfGalleriesRecieved object:nil];
    });
}

@end

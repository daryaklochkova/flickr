//
//  XMLParser.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 16/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "XMLParser.h"

@implementation XMLParser

- (void)parse:(NSData *) data{
    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:data];
    [nsXmlParser setDelegate:self];
    [nsXmlParser parse];
}

#pragma mark - NSXMLParser Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    [self.responseParser didStartElement:elementName attributes:attributeDict];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if ([self.responseParser respondsToSelector:@selector(foundCharacters:)]){
        [self.responseParser foundCharacters:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName{
    if ([self.responseParser respondsToSelector:@selector(didEndElement:)]){
        [self.responseParser didEndElement:elementName];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
    [self.responseParser didEndDocument];
}

- (Format)getFormatType{
    return XMLFormat;
}

@synthesize responseParser;

@end

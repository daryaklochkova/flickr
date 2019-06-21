//
//  ParserProvider.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 27/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "ParserProvider.h"
#import "XMLParser.h"
#import "JSONParser.h"


@implementation ParserProvider

+ (instancetype)defaultProvider{
    static dispatch_once_t onceToken;
    static id _sharedObject = nil;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}


- (id <Parser>)getParser {
    NSString *format = [[NSUserDefaults standardUserDefaults] objectForKey:[formatArgumentName copy]];
    
    if ([format isEqualToString:@"json"]){
        return [[XMLParser alloc] init];
    }
    else if ([format isEqualToString:@"xml"]) {
        return [[JSONParser alloc] init];
    }
    return  nil;
}

@end

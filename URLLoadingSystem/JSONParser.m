//
//  JSONParser.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 16/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "JSONParser.h"
@implementation JSONParser

@synthesize responseParser;

- (void)parse:(NSData *) data{
    
    NSError *error;
    NSDictionary * jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if (error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:dataParsingFailed object:@{errorKey:error}];
    }
    else {
        
        NSString *status = jsonDictionary[@"stat"];
        if ([status isEqualToString:@"fail"]){
            NSString *message = jsonDictionary[@"message"];
            NSString *code = jsonDictionary[@"code"];
            
            NSError *error = [NSError errorWithDomain:@"" code:[code intValue] userInfo:@{NSUnderlyingErrorKey:message}];
            [[NSNotificationCenter defaultCenter] postNotificationName:dataParsingFailed object:@{errorKey:error}];
        }
        
        [self parseDictionary:jsonDictionary];
        [self.responseParser didEndDocument];
    }
}

- (void)parseDictionary:(NSDictionary *)dictionary{
    
    for (NSString *key in dictionary) {
        id obj = dictionary[key];
        if ([obj isKindOfClass:[NSArray class]]){
            for (id elem in obj) {
                [self.responseParser didStartElement:key attributes:elem];
                
                if ([elem isKindOfClass:[NSDictionary class]]){
                    [self parseDictionary:elem];
                }
            }
        }
        else {
            [self.responseParser didStartElement:key attributes:@{key:obj}];
        }
        
        if ([obj isKindOfClass:[NSDictionary class]]){
            NSString * content = [(NSDictionary *)obj objectForKey:@"_content"];
            if (content){
                if ([self.responseParser respondsToSelector:@selector(foundCharacters:)]){
                    [self.responseParser foundCharacters:content];
                }
            }
            
            [self parseDictionary:obj];
        }
    }
}

- (Format)getFormatType{
    return JSONFormat;
}

- (NSString *)getStringFormatType{
    return @"json";
}

@end

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
    NSDictionary * jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    [self parseDictionary:jsonDictionary];
    
    [self.responseParser didEndDocument];
}

- (void)parseDictionary:(NSDictionary *)dictionary{
    
    for (NSString *key in dictionary) {
        id obj = [dictionary objectForKey:key];
        
        if ([obj isKindOfClass:[NSArray class]]){
            for (id elem in obj) {
                [self.responseParser didStartElement:key attributes:elem];
            }
        }
        else {
            [self.responseParser didStartElement:key attributes:@{key:obj}];
        }
        
        if ([obj isKindOfClass:[NSDictionary class]]){
            [self parseDictionary:obj];
        }
    }
}




@end

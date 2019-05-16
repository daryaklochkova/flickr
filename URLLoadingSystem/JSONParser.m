//
//  JSONParser.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 16/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "JSONParser.h"

@implementation JSONParser


- (void)parse:(NSData *) data{
    NSError *error;
    NSDictionary * jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
}

@end

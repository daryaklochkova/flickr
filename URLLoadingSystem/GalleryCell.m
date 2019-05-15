//
//  GalleryCell.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GalleryCell.h"

@implementation GalleryCell

- (instancetype) init{
    self = [super init];
    
    if (self){
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = true;
    }
    
    return self;
}

@end

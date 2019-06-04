//
//  GalleryCell.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GalleryCell.h"

@implementation GalleryCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureLayerSettings];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configureLayerSettings];
    }
    return self;
}

- (void)configureLayerSettings {
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = true;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.borderWidth = 1.0f;
}

- (void)prepareForReuse {
    self.imageView.image = nil;
    self.lable.text = @"";
}

@end

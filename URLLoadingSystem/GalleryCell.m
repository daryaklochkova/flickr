//
//  GalleryCell.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GalleryCell.h"

@interface GalleryCell()


@end

@implementation GalleryCell

@synthesize isCellSelected;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isCellSelected = NO;
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
    self.isCellSelected = NO;
    self.imageView.alpha = 1;
    [self.chooseLabel setHidden:YES];
}

- (void)selectItem {
    if (!self.isCellSelected) {
        self.imageView.alpha = 0.5;
        [self.chooseLabel setHidden:NO];
        self.isCellSelected = YES;
    }
    else {
        self.imageView.alpha = 1;
        [self.chooseLabel setHidden:YES];
        self.isCellSelected = NO;
    }
}

- (void)setText:(NSString *)text {
    self.lable.text = text;
}

- (void)setImage:(UIImage *)image {
    if (image) {
        self.imageView.image = image;
    }
}


@end

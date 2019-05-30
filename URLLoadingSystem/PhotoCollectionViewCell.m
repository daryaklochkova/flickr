//
//  PhotoCollectionViewCell.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 30/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@interface PhotoCollectionViewCell()
@property (strong, nonatomic) IBOutlet UICollectionViewCell *cell;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation PhotoCollectionViewCell

@synthesize imageView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        [self configureLayerSettings];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
        [self configureLayerSettings];
    }
    return self;
}

- (void)commonInit {
    [[[NSBundle mainBundle] loadNibNamed:@"PhotoCell" owner:self options:nil] firstObject];
    [self addSubview:self.cell];
    CGRect frame = self.cell.frame;
    self.imageView = [[UIImageView alloc] initWithFrame:frame];
    [self.cell addSubview:self.imageView];
}

- (void)configureLayerSettings {
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = true;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.borderWidth = 1.0f;
}

- (void)prepareForReuse {
    self.imageView.image = nil;
    [self.activityIndicator stopAnimating];
}

- (void)configureViewWithWidth:(CGFloat)width andHeight:(CGFloat)height {
    self.cell.frame = CGRectMake(0, 0, width, height);
    self.imageView.frame = self.cell.frame;
}

- (void)configureViewWithSize:(CGSize)size {
    self.cell.frame = CGRectMake(0, 0, size.width, size.height);
    self.imageView.frame = self.cell.frame;
}

- (void)startActivityIndicator {
    [self.activityIndicator startAnimating];
    [self.imageView setHidden:YES];
}

- (void)stopActivityIndicator {
    [self.activityIndicator stopAnimating];
    [self.imageView setHidden:NO];
}

@end

//
//  MainPhotoCollectionViewCell.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 30/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "MainPhotoCollectionViewCell.h"

@interface MainPhotoCollectionViewCell()
@property (strong, nonatomic) IBOutlet MainPhotoCollectionViewCell *cell;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MainPhotoCollectionViewCell

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
    [[[NSBundle mainBundle] loadNibNamed:@"MainPhotoCell" owner:self options:nil] firstObject];
    [self addSubview:self.cell];
    CGRect frame = self.cell.frame;
    self.imageView = [[UIImageView alloc] initWithFrame:frame];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.imageView];
}

- (void)configureLayerSettings {

}

- (void)configureViewWithSize:(CGSize)size {
    self.cell.frame = CGRectMake(0, 0, size.width, size.height);
    self.scrollView.frame = self.cell.frame;
    self.imageView.frame = self.cell.frame;
}

- (void)prepareForReuse {
    self.imageView.image = nil;
    [self.activityIndicator stopAnimating];
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

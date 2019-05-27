//
//  FooterCollectionReusableView.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 23/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "FooterCollectionReusableView.h"

@interface FooterCollectionReusableView()
@property (strong, nonatomic) IBOutlet UICollectionReusableView *contentView;
@end

@implementation FooterCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [[[NSBundle mainBundle] loadNibNamed:@"Footer" owner:self options:nil] firstObject];
    [self addSubview:self.contentView];
}

- (void)configViewWith:(CGFloat)width and:(CGFloat)height {
    self.contentView.frame = CGRectMake(0, 0, width, height);
}

@end

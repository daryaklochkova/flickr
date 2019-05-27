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

- (void)configureViewWithWidth:(CGFloat)width andHeight:(CGFloat)height {
    self.contentView.frame = CGRectMake(0, 0, width, height);
}

- (void)showWithWight:(CGFloat)width {
    [self configureViewWithWidth:width andHeight:30];
    [self.indicator startAnimating];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.indicator stopAnimating];
        [self configureViewWithWidth:width andHeight:0];
    });
}


@end

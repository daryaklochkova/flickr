//
//  FooterCollectionReusableView.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 23/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FooterCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

- (void)configureViewWithWidth:(CGFloat)width andHeight:(CGFloat)height;
- (void)showWithWight:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END

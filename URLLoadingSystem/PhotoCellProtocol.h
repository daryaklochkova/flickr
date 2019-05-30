//
//  PhotoCellProtocol.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 31/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PhotoCell <NSObject>

@property (strong, nonatomic) UIImageView *imageView;

- (void)configureViewWithSize:(CGSize)size;
- (void)startActivityIndicator;
- (void)stopActivityIndicator;

@end

NS_ASSUME_NONNULL_END

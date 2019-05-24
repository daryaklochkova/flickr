//
//  UIScrollView.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 23/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (ZoomToPoint)

- (void)zoomToPoint:(CGPoint)zoomPoint withScale: (CGFloat)scale animated: (BOOL)animated;

@end


NS_ASSUME_NONNULL_END

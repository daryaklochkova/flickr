//
//  PhotoViewController.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 08/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Gallery;

NS_ASSUME_NONNULL_BEGIN

@interface PhotoViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) Gallery *gallery;

@end

NS_ASSUME_NONNULL_END

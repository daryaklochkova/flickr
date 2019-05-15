//
//  PhotoViewController.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 08/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Gallery.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) Gallery *gallery;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

NS_ASSUME_NONNULL_END

//
//  GalleryPhotosViewController.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 08/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Gallery.h"
#import "PhotoViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GalleryPhotosViewController : UIViewController <UICollectionViewDataSource>

@property (strong, nonatomic) Gallery *gallery;

@end

NS_ASSUME_NONNULL_END

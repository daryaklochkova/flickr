//
//  GalleryCollectionViewDataSource.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 23/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Gallery.h"

NS_ASSUME_NONNULL_BEGIN

@interface GalleryCollectionViewDataSource : NSObject <UICollectionViewDataSource>

- (instancetype)initWithGallery:(Gallery *) gallery;
- (void)collectionView:(UICollectionView *)collectionView reloadItemAtIndex:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END

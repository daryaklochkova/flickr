//
//  MainPhotoCollectionViewCell.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 30/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainPhotoCollectionViewCell : UICollectionViewCell <PhotoCell, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

NS_ASSUME_NONNULL_END

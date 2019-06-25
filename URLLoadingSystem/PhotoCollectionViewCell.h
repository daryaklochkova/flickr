//
//  PhotoCollectionViewCell.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 30/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoCellProtocol.h"
#import "SelectableCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoCollectionViewCell : UICollectionViewCell <PhotoCell, SelectableCellProtocol>

@end

NS_ASSUME_NONNULL_END

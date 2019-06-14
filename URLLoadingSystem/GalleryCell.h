//
//  GalleryCell.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SelectableCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GalleryCell : UICollectionViewCell <SelectableCellProtocol>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *lable;
@property (weak, nonatomic) IBOutlet UIImageView *chooseLabel;

@end

NS_ASSUME_NONNULL_END

//
//  UICollectionView.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 10/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionView(getCellSize)

@property (strong, nonatomic) NSMutableSet<NSIndexPath *> *selectedCellsIndexPaths;

- (CGSize)getCellSizeAtIndexPath:(NSIndexPath *)indexPath;
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)cancelItemsSelection;
- (void)moveAllSelectedIndexes:(NSInteger)delta;

@end

NS_ASSUME_NONNULL_END

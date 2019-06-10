//
//  UICollectionView.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 10/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "UICollectionView.h"

@implementation UICollectionView(getCellSize)

- (CGSize)getCellSizeAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewFlowLayout* collectionViewLayout = (UICollectionViewFlowLayout*)[self collectionViewLayout];
    
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>) self.delegate;
        
        return [delegate collectionView:self layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    }
    else {
        return collectionViewLayout.itemSize;
    }
}

@end

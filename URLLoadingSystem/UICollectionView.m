//
//  UICollectionView.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 10/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "UICollectionView.h"
#import "SelectableCellProtocol.h"
#import <objc/runtime.h>

@implementation UICollectionView(getCellSize)

static char UIB_PROPERTY_KEY;
@dynamic selectedCellsIndexPaths;

//- (instancetype)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        self.selectedCellsIndexPaths = [NSMutableSet set];
//    }
//    return self;
//}

-(NSObject*)selectedCellsIndexPaths
{
    return (NSObject*)objc_getAssociatedObject(self, &UIB_PROPERTY_KEY);
}

- (void)setSelectedCellsIndexPaths:(NSMutableSet<NSIndexPath *> *)selectedCellsIndexPaths {
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY, selectedCellsIndexPaths, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *collectionViewCell = [self cellForItemAtIndexPath:indexPath];
    
    if ([collectionViewCell conformsToProtocol:@protocol(SelectableCellProtocol)]) {
        id<SelectableCellProtocol> cell = (id<SelectableCellProtocol>)collectionViewCell;
        [cell selectItem];
    }
    
    if ([self.selectedCellsIndexPaths containsObject:indexPath]) {
        [self.selectedCellsIndexPaths removeObject:indexPath];
    }
    else {
        [self.selectedCellsIndexPaths addObject:indexPath];
    }
}

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

- (void)cancelItemsSelection {
    for (NSIndexPath *indexPath in self.selectedCellsIndexPaths) {
        UICollectionViewCell *collectionViewCell = [self cellForItemAtIndexPath:indexPath];
        
        if ([collectionViewCell conformsToProtocol:@protocol(SelectableCellProtocol)]) {
            id<SelectableCellProtocol> cell = (id<SelectableCellProtocol>)collectionViewCell;
            [cell selectItem];
        }
    }
    
    self.selectedCellsIndexPaths = [NSMutableSet set];
}

- (void)moveAllSelectedIndexes:(NSInteger)delta {
    NSSet *indexes = self.selectedCellsIndexPaths;
    NSMutableSet *newIndexPathSet = [NSMutableSet set];
    
    for (NSIndexPath *indexPath in indexes) {
        NSInteger section = [indexPath indexAtPosition:0];
        NSInteger row = [indexPath indexAtPosition:1];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:row + 1 inSection:section];
        [newIndexPathSet addObject:newIndexPath];
    }
    indexes = newIndexPathSet;
};

@end

//
//  CellSizeProvider.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 17/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "CellSizeProvider.h"

@interface CellSizeProvider()

@property (assign, nonatomic) CGSize minCellSize;
@property (assign, nonatomic) CGSize cellSize;
@property (assign, nonatomic) NSInteger minSpacing;
@property (assign, nonatomic) CGFloat aspectRatio;

@property (assign, nonatomic) CGSize previousCollectionViewSize;

@end

@implementation CellSizeProvider

- (instancetype)initWithMinCellSize:(CGSize)minCellSize
                         minSpacing:(NSInteger)minSpacing {
    self = [super init];
    if (self) {
        self.minCellSize = minCellSize;
        self.minSpacing = minSpacing;
        self.cellSize = self.minCellSize;
        self.aspectRatio = self.minCellSize.width / self.minCellSize.height;
        self.previousCollectionViewSize = CGSizeMake(0, 0);
    }
    return self;
}

#pragma mark - Calculate values for collection view

- (void)recalculateCellSize:(CGSize)collectionViewSize {
    if (!CGSizeEqualToSize(collectionViewSize, self.previousCollectionViewSize)) {
        self.previousCollectionViewSize = collectionViewSize;
        NSInteger cellsWidth = collectionViewSize.width - self.minSpacing;
        NSInteger columnCount = cellsWidth / (self.minCellSize.width + self.minSpacing);
        
        NSInteger newCellWidth = (cellsWidth - (self.minSpacing * columnCount + self.minSpacing)) / columnCount;
        NSInteger newCellHeight = newCellWidth / self.aspectRatio;
        
        self.cellSize = CGSizeMake(newCellWidth, newCellHeight);
    }
}

- (CGSize)getCellSize {
    return CGSizeMake(self.cellSize.width, self.cellSize.height);
}

- (UIEdgeInsets)getEdgeInsets {
    return UIEdgeInsetsMake(10, self.minSpacing, 10, self.minSpacing);
}

@end

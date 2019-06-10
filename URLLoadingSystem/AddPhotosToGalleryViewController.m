//
//  AddPhotosToGalleryCollectionViewController.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 06/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "AddPhotosToGalleryViewController.h"
#import <Photos/Photos.h>
#import "PhotoCollectionViewCell.h"
#import "UICollectionView.h"

@interface AddPhotosToGalleryViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (strong, nonatomic) PHFetchResult<PHAsset *> *assets;

@property (strong, nonatomic) NSMutableSet<NSIndexPath *> *selectedCellsIndexPath;
@end

@implementation AddPhotosToGalleryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedCellsIndexPath = [NSMutableSet set];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.assets = [PHAsset fetchAssetsWithOptions:options];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    CGSize cellSize = [collectionView getCellSizeAtIndexPath:indexPath];
    [cell configureViewWithSize:cellSize];
    
    NSUInteger index = [indexPath indexAtPosition:1];
    PHAsset *asset = [self.assets objectAtIndex:index];
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:cellSize contentMode:PHImageContentModeDefault options:[[PHImageRequestOptions alloc] init] resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.imageView.image = result;
    }];
    
    if ([self.selectedCellsIndexPath containsObject:indexPath]) {
        [cell selectItem];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *collectionViewCell = [collectionView cellForItemAtIndexPath:indexPath];
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)collectionViewCell;
    [cell selectItem];
    
    if ([self.selectedCellsIndexPath containsObject:indexPath]) {
        [self.selectedCellsIndexPath removeObject:indexPath];
    } else {
        [self.selectedCellsIndexPath addObject:indexPath];
    }
}

#pragma mark - IBActions

- (IBAction)done:(id)sender {
    if (!self.selectedImages) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    for (NSIndexPath *indexPath in self.selectedCellsIndexPath) {
        NSUInteger index = [indexPath indexAtPosition:1];
        PHAsset *asset = [self.assets objectAtIndex:index];
        
        PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
        
        __weak typeof(self) weakSelf = self;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf.selectedImages addObject:result];
        }];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

@end

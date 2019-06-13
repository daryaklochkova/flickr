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
@property (strong, nonatomic) PHCachingImageManager *cachingManager;

@end

@implementation AddPhotosToGalleryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedCellsIndexPath = [NSMutableSet set];
    
    [self fetchAssetsFromPhotoLibrary];
}

#pragma mark - Work with PhotoKit

- (void)cacheAssets {
    NSMutableArray *assetsArray = [NSMutableArray array];
    for (PHAsset *asset in self.assets) {
        [assetsArray addObject:asset];
    }
    
    CGSize cellSize = [self.photosCollectionView getCellSizeAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    
    self.cachingManager = [[PHCachingImageManager alloc] init];
    [self.cachingManager startCachingImagesForAssets:assetsArray targetSize:cellSize contentMode:PHImageContentModeDefault options:imageOptions];
}

- (void)fetchAssetsFromPhotoLibrary {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.assets = [PHAsset fetchAssetsWithOptions:options];
    
    [self cacheAssets];
}

- (void)saveSelectedPhotos {
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.synchronous = YES;
    
    __weak typeof(self) weakSelf = self;
    
    for (NSIndexPath *indexPath in self.selectedCellsIndexPath) {
        NSUInteger index = [indexPath indexAtPosition:1];
        PHAsset *asset = [self.assets objectAtIndex:index];
        
        CGSize size = CGSizeMake(asset.pixelWidth, asset.pixelWidth);
        
        @autoreleasepool {
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf.selectedImages addObject:result];
            }];
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    CGSize cellSize = [collectionView getCellSizeAtIndexPath:indexPath];
    [cell configureViewWithSize:cellSize];
    
    NSUInteger index = [indexPath indexAtPosition:1];
    PHAsset *asset = [self.assets objectAtIndex:index];
    
    [self.cachingManager requestImageForAsset:asset targetSize:cellSize contentMode:PHImageContentModeDefault options:[[PHImageRequestOptions alloc] init] resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
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
    }
    else {
        [self.selectedCellsIndexPath addObject:indexPath];
    }
}


#pragma mark - IBActions

- (IBAction)done:(id)sender {
    
    if (!self.selectedImages) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [self saveSelectedPhotos];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

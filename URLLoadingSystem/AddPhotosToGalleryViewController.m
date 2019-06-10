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
@property (strong, nonatomic) NSMutableArray<UIImage *> *images;
@end

@implementation AddPhotosToGalleryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.images = [NSMutableArray array];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult<PHAsset *> * assets = [PHAsset fetchAssetsWithOptions:options];
    
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    //imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    imageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    CGSize size = CGSizeMake(100, 100);
    
    __weak typeof(self) weakSelf = self;
    for (PHAsset *asset in assets) {
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf.images addObject:result];
        }];
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    CGSize cellSize = [collectionView getCellSizeAtIndexPath:indexPath];
    [cell configureViewWithSize:cellSize];
    
    UIImage *image = [self.images objectAtIndex:[indexPath indexAtPosition:1]];
    cell.imageView.image = image;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell selectItem];
}

@end

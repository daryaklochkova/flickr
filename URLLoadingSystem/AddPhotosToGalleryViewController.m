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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return  2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return  1;
    }
    return self.assets.count;
}

- (BOOL)isCameraCell:(NSIndexPath *)indexPath {
    if ([indexPath indexAtPosition:0] == 0) {
        return YES;
    }
    
    return NO;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isCameraCell:indexPath]) {
        PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CameraCell" forIndexPath:indexPath];
        return cell;
    }
    
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
    
    if ([self isCameraCell:indexPath]) {
        [self launchCamera];
        return;
    }
    
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


- (void)launchCamera {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        [self showErrorAlertWithTitle:@"Error" andMessage:@"Device has no camera"];
        
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)showErrorAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleCancel
                             handler:nil];
    
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            NSLog (@"%@", error);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self moveAllSelectedIndexes:1];
                [self fetchAssetsFromPhotoLibrary];
                [self.photosCollectionView reloadData];
            });
        }
    }];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)moveAllSelectedIndexes:(NSInteger)delta {
    NSMutableSet *newIndexPathSet = [NSMutableSet set];
    for (NSIndexPath *indexPath in self.selectedCellsIndexPath) {
        NSInteger section = [indexPath indexAtPosition:0];
        NSInteger row = [indexPath indexAtPosition:1];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:row + 1 inSection:section];
        [newIndexPathSet addObject:newIndexPath];
    }
    self.selectedCellsIndexPath = newIndexPathSet;
};

@end

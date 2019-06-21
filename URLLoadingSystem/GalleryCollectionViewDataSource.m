//
//  GalleryCollectionViewDataSource.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 23/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GalleryCollectionViewDataSource.h"
#import "FooterCollectionReusableView.h"
#import "GalleryHeaderCollectionReusableView.h"
#import "PhotoCollectionViewCell.h"
#import "UICollectionView.h"

typedef void(^returnImageBlock)(UIImage *image);

@interface GalleryCollectionViewDataSource()
@property (strong, nonatomic) Gallery *gallery;
@property (strong, nonatomic) NSString *cellIdentifier;
@end

@implementation GalleryCollectionViewDataSource

- (instancetype)initWithGallery:(Gallery *) gallery
         andCellReuseIdentifier:(NSString *) cellIdentifier {
    self = [super init];
    
    if (!self) return nil;
    
    self.gallery = gallery;
    self.cellIdentifier = cellIdentifier;
    
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.gallery getPhotosCount];
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    if ([cell conformsToProtocol:@protocol(PhotoCell)]) {
        
        id<PhotoCell> photoCell = (id<PhotoCell>)cell;
        
        CGSize cellSize = [collectionView getCellSizeAtIndexPath:indexPath];
        [photoCell configureViewWithSize:cellSize];
        
        Photo *photo = [self.gallery.photos objectAtIndex:[indexPath indexAtPosition:1]];
        
        [self loadPhotoFromCashe:photo completionHandler:^(UIImage *image) {
            [self setImage:image toCell:photoCell];
        }];
    }
    
    return cell;
}

- (void)loadPhotoFromCashe:(Photo *)photo completionHandler:(returnImageBlock)completionHandler {
    NSString *filePath = [self.gallery getLocalPathForPhoto:photo];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(image);
            });
        }
    });
}


#pragma mark - Update Collection view

- (void)collectionView:(UICollectionView *)collectionView
     reloadItemAtIndex:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell) {
        Photo *photo = [self.gallery.photos objectAtIndex:[indexPath indexAtPosition:1]];
        if ([cell conformsToProtocol:@protocol(PhotoCell)]) {
            [self loadPhotoFromCashe:photo completionHandler:^(UIImage *image) {
                [self setImage:image toCell:(id<PhotoCell>)cell];
            }];
        }
    }
}

- (BOOL)setImage:(UIImage *)image toCell:(id <PhotoCell>)cell {
    if (image) {
        [cell setImageToImageView:image];
        return YES;
    }
    
    NSLog(@"%@ image doesn't exist", NSStringFromSelector(_cmd));
    [cell startActivityIndicator];
    return NO;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *supplementaryElement = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Footer" forIndexPath:indexPath];
        
        return supplementaryElement;
    }
    else {
        UICollectionReusableView *supplementaryElement = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"GalleryHeader" forIndexPath:indexPath];
        
        GalleryHeaderCollectionReusableView *header = (GalleryHeaderCollectionReusableView *)supplementaryElement;
        
        header.titleTextField.text = self.gallery.title;
        
        return supplementaryElement;
    }
}

@end

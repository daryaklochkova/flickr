//
//  GalleryCollectionViewDataSource.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 23/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GalleryCollectionViewDataSource.h"


@interface GalleryCollectionViewDataSource()

@property (strong, nonatomic) Gallery *gallery;

@end

@implementation GalleryCollectionViewDataSource

- (instancetype)initWithGallery:(Gallery *) gallery{
    self = [super init];
    
    if (!self) return nil;
    
    self.gallery = gallery;
    
    return self;
}

#pragma mark - UICollectionViewDataSource

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    cell.layer.cornerRadius = 10;
    cell.layer.masksToBounds = true;
    
    Photo *photo = [self.gallery.photos objectAtIndex:[indexPath indexAtPosition:1]];
    [self setPhoto:photo toCell:cell];
    
    if ([self setPhoto:photo toCell:cell] == NO){
        [self setActivityIndicatorToCell:cell];
    }
    
    return cell;
}


- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;//[self.gallery getPhotosCount];
}

#pragma mark - update Collection view

- (void)collectionView:(UICollectionView *)collectionView reloadItemAtIndex:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell){
        Photo *photo = [self.gallery.photos objectAtIndex:[indexPath indexAtPosition:1]];
        [self setPhoto:photo toCell:cell];
    }
}

- (BOOL)setPhoto:(Photo *) photo toCell:(UICollectionViewCell *) cell {
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[self.gallery getLocalPathForPhoto:photo]];
    
    //if (image) {
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flickrTest"]]; //[[UIImageView alloc] initWithImage:image];
        cell.userInteractionEnabled = YES;
        return YES;
    //}
    return NO;
}

- (void)setActivityIndicatorToCell:(UICollectionViewCell *) cell{
    UIActivityIndicatorView * downloadActivityIndicator = [[UIActivityIndicatorView alloc] init];
    
    downloadActivityIndicator.backgroundColor = [UIColor grayColor];
    [downloadActivityIndicator startAnimating];
    
    cell.backgroundView = downloadActivityIndicator;
    cell.userInteractionEnabled = NO;
}

@end
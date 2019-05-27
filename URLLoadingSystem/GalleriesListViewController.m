//
//  ViewController.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 06/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GalleriesListViewController.h"
#include "AppDelegate.h"
#include "FooterCollectionReusableView.h"
#include "UIScrollView.h"

@interface GalleriesListViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *listOfGalleriesCollectionView;
@property (strong, nonatomic) Gallery *selectedGallery;
@property (strong, nonatomic) FooterCollectionReusableView *collectionViewFooter;
@end

@implementation GalleriesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadListOfGalleries];
    [self subscribeToNotifications];
}

- (void)loadListOfGalleries{
    self.listOfGalleries = [[ListOfGalleries alloc] initWithUserID:@"66956608@N06"];//26144115@N06 @"66956608@N06"
    GalleriesListProvider *dataProvider = [[GalleriesListProvider alloc] init];
    [self.listOfGalleries setDataProvider:dataProvider];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.listOfGalleries updateContent];
    });
}

- (void)subscribeToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewContent)
                                                 name:ListOfGalleriesSuccessfulRecieved object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadItem:)
                                                 name:PrimaryPhotoDownloadComplite object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlert:)
                                                 name:dataFetchError object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlert:)
                                                 name:dataParsingFailed object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - update interface

- (void)showAlert:(NSNotification *)notification {
    
    NSError *error = [[notification userInfo] objectForKey:errorKey];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Data loading failed" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateViewContent {
    [self.listOfGalleriesCollectionView reloadData];
}

- (void)reloadItem:(NSNotification *)notification {
    NSNumber * number = [[notification object] valueForKey:galleryIndex];
    NSInteger index = [number integerValue];
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    UICollectionViewCell *cell = [self.listOfGalleriesCollectionView cellForItemAtIndexPath:indexPath];
    
    if (cell && [cell isKindOfClass:[GalleryCell class]]){
        GalleryCell * galleryCell = (GalleryCell *)cell;
        Gallery *gallery = [self.listOfGalleries getGalleryAtIndex:[indexPath indexAtPosition:1]];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:[gallery getLocalPathForPhoto:gallery.primaryPhoto]];
        
        if (image) {
            galleryCell.imageView.image = image;
        }
    }
}


#pragma mark - UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionFooter){
        
        UICollectionReusableView *supplementaryElement = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Footer" forIndexPath:indexPath];
        
        if ([supplementaryElement isKindOfClass:[FooterCollectionReusableView class]]) {
            FooterCollectionReusableView *footer = (FooterCollectionReusableView *)supplementaryElement;
            
            self.collectionViewFooter = footer;
            return footer;
        }
    }
    
    return nil;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
    
    Gallery *gallery = [self.listOfGalleries getGalleryAtIndex:[indexPath indexAtPosition:1]];
    
    NSString *primaryPhotoPath = [gallery getLocalPathForPhoto:gallery.primaryPhoto];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:primaryPhotoPath]){
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:primaryPhotoPath];
        
        if (image) {
            cell.imageView.image = image;
        }
    }
    cell.lable.text = gallery.title;
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.listOfGalleries countOfGalleries];
}

#pragma mark - Prepare for seque

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    UIViewController *destinationVC = [segue destinationViewController];
    
    if ([destinationVC isKindOfClass:[GalleryPhotosViewController class]]){
        GalleryPhotosViewController *destinationController = (GalleryPhotosViewController *)destinationVC;
        destinationController.gallery = self.selectedGallery;
    }
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [indexPath indexAtPosition:1];
    self.selectedGallery = [self.listOfGalleries getGalleryAtIndex:index];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if ([scrollView isBottomReached]) {
        CGFloat width = self.listOfGalleriesCollectionView.frame.size.width;
        [self.collectionViewFooter showWithWight:width];
        [self.listOfGalleries getAdditionalContent];
    }
}


@end

//
//  ViewController.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 06/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GalleriesListViewController.h"
#include "AppDelegate.h"

@interface GalleriesListViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *listOfGalleriesCollectionView;
@property (strong, nonatomic) Gallery *selectedGallery;


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

- (void)subscribeToNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewContent)
                                                 name:ListOfGalleriesSuccessfulRecieved object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadItem:)
                                                 name:PrimaryPhotoDownloadComplite object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlert:)
                                                 name:dataFetchError object:nil];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma MARK - update interface

- (void)showAlert:(NSNotification *) notification{
    
    NSError *error = [[notification userInfo] objectForKey:errorKey];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Data loading failed" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)updateViewContent{
    [self.listOfGalleriesCollectionView reloadData];
}


- (void)reloadItem:(NSNotification *) notification{
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

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    GalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
    
    Gallery *gallery = [self.listOfGalleries getGalleryAtIndex:[indexPath indexAtPosition:1]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[gallery getLocalPathForPhoto:gallery.primaryPhoto]]){
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:[gallery getLocalPathForPhoto:gallery.primaryPhoto]];
        
        if (image) {
            cell.imageView.image = image;
        }
    }
    cell.lable.text = gallery.title;
    cell.layer.cornerRadius = 4;
    cell.layer.masksToBounds = true;
    return cell;
}


- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.listOfGalleries countOfGalleries];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue destinationViewController] isKindOfClass:[GalleryPhotosViewController class]]){
        GalleryPhotosViewController *destinationController = (GalleryPhotosViewController *)[segue destinationViewController];
        destinationController.gallery = self.selectedGallery;
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedGallery = [self.listOfGalleries getGalleryAtIndex:[indexPath indexAtPosition:1]];
}


@end

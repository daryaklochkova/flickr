//
//  ViewController.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 06/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GalleriesListViewController.h"
#import "AppDelegate.h"
#import "FooterCollectionReusableView.h"
#import "UIScrollView.h"

@interface GalleriesListViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *listOfGalleriesCollectionView;
@property (strong, nonatomic) Gallery *selectedGallery;
@property (strong, nonatomic) FooterCollectionReusableView *collectionViewFooter;
@property (assign, nonatomic) BOOL isUpdateStarted;

@property (assign, nonatomic) CGSize minCellSize;
@property (assign, nonatomic) CGSize cellSize;
@property (assign, nonatomic) NSInteger minSpacing;
@property (assign, nonatomic) CGFloat aspectRatio;
@end

@implementation GalleriesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadListOfGalleries];
    [self subscribeToNotifications];
    self.isUpdateStarted = NO;
    
    self.minCellSize = CGSizeMake(173, 236);
    self.cellSize = self.minCellSize;
    self.minSpacing = 10;
    self.aspectRatio = (CGFloat)173 / (CGFloat)236;
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.listOfGalleriesCollectionView reloadData];
}

- (void)loadListOfGalleries{
    self.listOfGalleries = [[ListOfGalleries alloc] initWithUserID:@"66956608@N06"];//26144115@N06 @"66956608@N06"
    GalleriesListProvider *dataProvider = [[GalleriesListProvider alloc] init];
    [self.listOfGalleries setDataProvider:dataProvider];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.isUpdateStarted = YES;
        [self.listOfGalleries updateContent];
    });
}

- (void)subscribeToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listOfGalleriesRecieved:)
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

#pragma mark - Notifications handlers

- (void)listOfGalleriesRecieved:(NSNotification *)notification {
    self.isUpdateStarted = NO;
    [self updateViewContent];
}

#pragma mark - Update interface

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


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (!self.isUpdateStarted && [scrollView isBottomReached]) {
        CGFloat width = self.listOfGalleriesCollectionView.frame.size.width;
        [self.collectionViewFooter showWithWight:width];
        [self.listOfGalleries getAdditionalContent];
        self.isUpdateStarted = YES;
        NSLog(@"BottomReached");
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [indexPath indexAtPosition:1];
    self.selectedGallery = [self.listOfGalleries getGalleryAtIndex:index];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, self.minSpacing, 10, self.minSpacing);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    [self recalculateCellSize];
    return CGSizeMake(self.cellSize.width, self.cellSize.height);
}

- (void)recalculateCellSize {
    UICollectionView *collectionView = self.listOfGalleriesCollectionView;
    NSInteger cellsWidth = collectionView.frame.size.width - self.minSpacing;
    NSInteger columnCount = cellsWidth / (self.minCellSize.width + self.minSpacing);
    
    NSInteger newCellWidth = (cellsWidth - (self.minSpacing * columnCount + self.minSpacing)) / columnCount;
    NSInteger newCellHeight = newCellWidth / self.aspectRatio;
    
    self.cellSize = CGSizeMake(newCellWidth, newCellHeight);
}

@end

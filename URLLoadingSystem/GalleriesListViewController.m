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
#import "Constants.h"
#import "AddGalleryViewController.h"
#import "LocalGalleriesListProvider.h"

@interface GalleriesListViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *listOfGalleriesCollectionView;
@property (strong, nonatomic) Gallery *selectedGallery;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *addButton;


@property (strong, nonatomic) FooterCollectionReusableView *collectionViewFooter;
@property (assign, nonatomic) BOOL isUpdateStarted;
@property (assign, nonatomic) BOOL isUserOwner;

@property (assign, nonatomic) CGSize minCellSize;
@property (assign, nonatomic) CGSize cellSize;
@property (assign, nonatomic) NSInteger minSpacing;
@property (assign, nonatomic) CGFloat aspectRatio;
@property (assign, nonatomic) NSIndexPath *displayItem;
@end

@implementation GalleriesListViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *logdedInUserID = [[NSUserDefaults standardUserDefaults] objectForKey:[LoginedUserID copy]];
    self.isUserOwner = [self.user.userID isEqualToString:logdedInUserID];
    if (self.isUserOwner) {
        [self.addButton setHidden:NO];
    }
    
    [self.activityIndicator startAnimating];
    [self loadListOfGalleries];
    [self subscribeToNotifications];
    self.isUpdateStarted = NO;
    
    [self setCellSizeAndSpacing];
    
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    self.displayItem = [self.listOfGalleriesCollectionView.indexPathsForVisibleItems firstObject];
    [self.listOfGalleriesCollectionView.collectionViewLayout invalidateLayout];
}

- (void)viewDidLayoutSubviews {
    [self recalculateCellSize];
    [super viewDidLayoutSubviews];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initialization

- (void)loadListOfGalleries {
    
    if (!self.user) {
        self.user = [[User alloc] initWithUserID:@"66956608@N06" andName:@""];//26144115@N06 @"66956608@N06"
    }
    
    self.listOfGalleries = [[ListOfGalleries alloc] initWithUser:self.user];
    
    id <GalleriesListProviderProtocol> dataProvider;
    if (self.isUserOwner) {
        dataProvider = [[LocalGalleriesListProvider alloc] init];
    }
    else {
        dataProvider = [[GalleriesListProvider alloc] init];
    }
    
    [self.listOfGalleries setDataProvider:dataProvider];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.isUpdateStarted = YES;
        [self.listOfGalleries updateContent];
    });
}

- (void)setCellSizeAndSpacing {
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)[self.listOfGalleriesCollectionView collectionViewLayout];
    
    self.minCellSize = [collectionViewLayout itemSize];
    self.cellSize = self.minCellSize;
    self.minSpacing = [collectionViewLayout minimumLineSpacing];
    self.aspectRatio = self.minCellSize.width / self.minCellSize.height;
    self.displayItem = 0;
}

- (void)subscribeToNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self selector:@selector(listOfGalleriesRecieved:)
                               name:ListOfGalleriesSuccessfulRecieved
                             object:nil];
    
    [notificationCenter addObserver:self selector:@selector(reloadItem:)
                               name:PrimaryPhotoDownloadComplite
                             object:nil];
    
    [notificationCenter addObserver:self selector:@selector(showAlert:)
                               name:dataFetchError
                             object:nil];
    
    [notificationCenter addObserver:self selector:@selector(showAlert:)
                               name:dataParsingFailed
                             object:nil];
    
    [notificationCenter addObserver:self selector:@selector(deviceOrientationDidChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Notifications handlers

- (void)deviceOrientationDidChanged:(NSNotification *)notification {
    [self.listOfGalleriesCollectionView scrollToItemAtIndexPath:self.displayItem
                                               atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                       animated:NO];
}

- (void)listOfGalleriesRecieved:(NSNotification *)notification {
    self.isUpdateStarted = NO;
    [self updateViewContent];
    [self.activityIndicator stopAnimating];
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"scrollViewDidEndDragging");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //NSLog(@"scrollViewDidScroll");
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
    return CGSizeMake(self.cellSize.width, self.cellSize.height);
}

#pragma mark - Calculate values for collection view

- (void)recalculateCellSize {
    CGSize collectionViewSize = self.listOfGalleriesCollectionView.frame.size;
    NSInteger cellsWidth = collectionViewSize.width - self.minSpacing;
    NSInteger columnCount = cellsWidth / (self.minCellSize.width + self.minSpacing);
    
    NSInteger newCellWidth = (cellsWidth - (self.minSpacing * columnCount + self.minSpacing)) / columnCount;
    NSInteger newCellHeight = newCellWidth / self.aspectRatio;
    
    self.cellSize = CGSizeMake(newCellWidth, newCellHeight);
}

#pragma mark - User actions

- (IBAction)addGalleryPressed:(id)sender {
    UIStoryboard *nextStoryBoard = [UIStoryboard storyboardWithName:@"AddGallery" bundle:nil];
    AddGalleryViewController *nextViewController = [nextStoryBoard instantiateInitialViewController];
    nextViewController.galleryOwner = self.user;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

@end

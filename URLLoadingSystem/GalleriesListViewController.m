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
#import "PermissionManager.h"
#import "WorkModes.h"
#import "UICollectionView.h"
#import "CellSizeProvider.h"
#import "AlertManager.h"

@interface GalleriesListViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *listOfGalleriesCollectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIToolbar *editGalleriesToolbar;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *selectItem;

@property (strong, nonatomic) Gallery *selectedGalleryForSegue;
@property (strong, nonatomic) FooterCollectionReusableView *collectionViewFooter;
@property (assign, nonatomic) BOOL isUpdateStarted;
@property (assign, nonatomic) BOOL isUserOwner;

@property (assign, nonatomic) NSIndexPath *displayItem;
@property (assign, nonatomic) WorkMode workMode;

@property (strong, nonatomic) id<CellSizeProvider> cellSizeProvider;

@end

@implementation GalleriesListViewController
@synthesize needReloadContent;

#pragma mark - UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.listOfGalleriesCollectionView.selectedCellsIndexPaths = [NSMutableSet set];
    
    if ([[PermissionManager defaultManager] isLoginedUserHasPermissionForEditing:self.owner]) {
        [self.selectItem setEnabled:YES];
        self.selectItem.title = NSLocalizedString(@"Select", nil);
        self.isUserOwner = YES;
    }
    self.workMode = readMode;
    
    [self loadListOfGalleries];
    [self.activityIndicator startAnimating];
    [self subscribeToNotifications];
    self.isUpdateStarted = NO;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.listOfGalleriesCollectionView.collectionViewLayout;
    
    self.cellSizeProvider = [[CellSizeProvider alloc] initWithMinCellSize:layout.itemSize minSpacing:layout.minimumLineSpacing];
    self.displayItem = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.workMode == editMode) {
        [self editingDone:self.editItem];
    }    
    
    if (self.needReloadContent) {
        [self loadListOfGalleries];
        [self.listOfGalleriesCollectionView reloadData];
        self.needReloadContent = NO;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    self.displayItem = [self.listOfGalleriesCollectionView.indexPathsForVisibleItems firstObject];
    [self.listOfGalleriesCollectionView.collectionViewLayout invalidateLayout];
}

- (void)viewDidLayoutSubviews {
    CGSize collectionViewSize = self.listOfGalleriesCollectionView.frame.size;
    [self.cellSizeProvider recalculateCellSize:collectionViewSize];
    [super viewDidLayoutSubviews];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initialization

- (void)loadListOfGalleries {
    self.listOfGalleries = [[ListOfGalleries alloc] initWithUser:self.owner];
    
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

#pragma mark - Subscribe to notifications

- (void)subscribeToNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(listOfGalleriesRecieved:)
                               name:ListOfGalleriesSuccessfulRecieved
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(reloadItem:)
                               name:PrimaryPhotoDownloadComplite
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(showAlert:)
                               name:dataFetchError
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(showAlert:)
                               name:dataParsingFailed
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(deviceOrientationDidChanged:)
                               name:UIDeviceOrientationDidChangeNotification object:nil];
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

- (void)setImageFor:(GalleryCell *)cell byPath:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        @autoreleasepool {
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            [cell setImage:image];
        }
    }
}

- (void)switchNavigationItems {
    if ([self isAllowDeleteGallery]) {
        [self.trashItem setEnabled:YES];
    } else {
        [self.trashItem setEnabled:NO];
    }
    if ([self isAllowEditGallery]) {
        [self.editItem setEnabled:YES];
    }
    else {
        [self.editItem setEnabled:NO];
    }
}

- (void)showAlert:(NSNotification *)notification {
    
    NSError *error = [[notification userInfo] objectForKey:errorKey];
    
    UIAlertController *alertController = [[AlertManager defaultManager] showErrorAlertWithTitle:NSLocalizedString(@"Data loading failed", nil) andMessage:[error localizedDescription]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateViewContent {
    [self.listOfGalleriesCollectionView reloadData];
}

- (Gallery *)getGalleryForCellAtIndexPath:(NSIndexPath *)indexPath {
    return [self.listOfGalleries getGalleryAtIndex:[indexPath indexAtPosition:1]];
}

- (void)reloadItem:(NSNotification *)notification {
    NSNumber * number = [[notification object] valueForKey:galleryIndex];
    NSInteger index = [number integerValue];
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    UICollectionViewCell *cell = [self.listOfGalleriesCollectionView cellForItemAtIndexPath:indexPath];
    
    if (cell && [cell isKindOfClass:[GalleryCell class]]){
        Gallery *gallery = [self getGalleryForCellAtIndexPath:indexPath];
        NSString *path = [gallery getLocalPathForPhoto:gallery.primaryPhoto];
        [self setImageFor:(GalleryCell *)cell byPath:path];
    }
}


#pragma mark - UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionFooter) {
        
        UICollectionReusableView *supplementaryElement = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Footer" forIndexPath:indexPath];
        
        if ([supplementaryElement isKindOfClass:[FooterCollectionReusableView class]]) {
            FooterCollectionReusableView *footer = (FooterCollectionReusableView *)supplementaryElement;
            
            self.collectionViewFooter = footer;
            return footer;
        }
    }
    
    return nil;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
    
    Gallery *gallery = [self getGalleryForCellAtIndexPath:indexPath];
    
    [self setImageFor:cell byPath:[gallery getLocalPathForPrimaryPhoto]];
    [cell setText:gallery.title];
    
    if ([self isCellByIndexPathWasSelected:indexPath]) {
        [cell selectItem];
    }
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.listOfGalleries countOfGalleries];
}

#pragma mark - Segue methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    UIViewController *destinationVC = [segue destinationViewController];
    
    if ([destinationVC isKindOfClass:[GalleryPhotosViewController class]]){
        GalleryPhotosViewController *destinationController = (GalleryPhotosViewController *)destinationVC;
        destinationController.gallery = self.selectedGalleryForSegue;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
    if (self.workMode == editMode) {
        return NO;
    }
    return YES;
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
    if (self.workMode == readMode) {
        self.selectedGalleryForSegue = [self getGalleryForCellAtIndexPath:indexPath];
    } else if (self.workMode == editMode) {
        [collectionView selectItemAtIndexPath:indexPath];
        [self switchNavigationItems];
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return [self.cellSizeProvider getEdgeInsets];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellSizeProvider getCellSize];
}

#pragma mark - Navigation

- (void)pushAddGalleryViewController:(Gallery *)editGallery {
    UIStoryboard *nextStoryBoard = [UIStoryboard storyboardWithName:@"AddGallery" bundle:nil];
    AddGalleryViewController *nextViewController = [nextStoryBoard instantiateInitialViewController];
    nextViewController.galleryOwner = self.owner;
    nextViewController.galleries = self.listOfGalleries;
    
    if (editGallery) {
        nextViewController.editGallery = editGallery;
    }
    
    [self.navigationController pushViewController:nextViewController animated:YES];
}

#pragma mark - User actions

- (IBAction)addGalleryPressed:(id)sender {
    [self pushAddGalleryViewController: nil];
}

- (IBAction)EnableEditMode:(id)sender {
    if (self.workMode == readMode) {
        self.workMode = editMode;
        [self.editGalleriesToolbar setHidden:NO];
        self.selectItem.title = NSLocalizedString(@"Cancel", nil);
    }
    else {
        self.workMode = readMode;
        [self.editGalleriesToolbar setHidden:YES];
        [self.listOfGalleriesCollectionView cancelItemsSelection];
        self.selectItem.title = NSLocalizedString(@"Select", nil);
    }
}

- (IBAction)editingDone:(id)sender {
    self.workMode = readMode;
    [self.editGalleriesToolbar setHidden:YES];
    [self.listOfGalleriesCollectionView cancelItemsSelection];
    [self.trashItem setEnabled:NO];
    [self.editItem setEnabled:NO];
    self.selectItem.title = NSLocalizedString(@"Select", nil);
}

- (IBAction)deleteItems:(id)sender {
    NSMutableSet *galleryIDs = [NSMutableSet set];
    
    for (NSIndexPath *indexPath in self.listOfGalleriesCollectionView.selectedCellsIndexPaths) {
        NSString *galleryID = [self getGalleryForCellAtIndexPath:indexPath].galleryID;
        [galleryIDs addObject:galleryID];
    }
    
    [self.listOfGalleries deleteGallery:galleryIDs];
    [self.listOfGalleriesCollectionView cancelItemsSelection];
    [self.listOfGalleriesCollectionView reloadData];
}

- (IBAction)editGalleryInfo:(id)sender {
    NSSet *indexes = self.listOfGalleriesCollectionView.selectedCellsIndexPaths;
    if (indexes.count == 1) {
        NSIndexPath *index = [indexes.allObjects firstObject];
        Gallery *editGallery = [self getGalleryForCellAtIndexPath:index];
        [self pushAddGalleryViewController:editGallery];
    }
}

#pragma mark - Check some conditions

- (BOOL)isCellByIndexPathWasSelected:(NSIndexPath *)indexPath {
    NSSet *selectedItems = self.listOfGalleriesCollectionView.selectedCellsIndexPaths;
    return [selectedItems containsObject:indexPath];
}

- (BOOL)isAllowDeleteGallery {
    NSSet *selectedItems = self.listOfGalleriesCollectionView.selectedCellsIndexPaths;
    return selectedItems.count > 0;
}

- (BOOL)isAllowEditGallery {
    NSSet *selectedItems = self.listOfGalleriesCollectionView.selectedCellsIndexPaths;
    return selectedItems.count == 1;
}

@end

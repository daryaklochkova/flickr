//
//  GalleryPhotosViewController.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 08/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GalleryPhotosViewController.h"
#import "GalleryCollectionViewDataSource.h"
#import "FooterCollectionReusableView.h"
#import "UIScrollView.h"
#import "GalleryHeaderCollectionReusableView.h"
#import "PermissionManager.h"
#import "WorkModes.h"
#import "AddPhotosToGalleryViewController.h"
#import "PhotoCollectionViewCell.h"
#import "AlertManager.h"

@interface GalleryPhotosViewController()

@property (weak, nonatomic) IBOutlet UICollectionView *galleryCollectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trash;


@property (strong, nonatomic) GalleryCollectionViewDataSource *collectionViewDataSource;
@property (assign, nonatomic) WorkMode workMode;

@property (strong, nonatomic) NSMutableArray *selectedImages;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editItem;

@property (strong, nonatomic) NSMutableSet<NSIndexPath *> *selectedCellsIndexPath;
@end


@implementation GalleryPhotosViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadGalleryContent];
    [self subscribeToNotifications];
    [self.galleryCollectionView setHidden:YES];
    self.selectedImages = [NSMutableArray array];
    self.selectedCellsIndexPath = [NSMutableSet set];
    
    self.collectionViewDataSource = [[GalleryCollectionViewDataSource alloc] initWithGallery:self.gallery andCellReuseIdentifier:@"PhotoCell"];
    self.galleryCollectionView.dataSource = self.collectionViewDataSource;
    self.galleryCollectionView.delegate = self;
    
    
    self.workMode = readMode;
    if ([[PermissionManager defaultManager] isLoginedUserHasPermissionForEditing:self.gallery.owner]) {
        [self.editItem setEnabled:YES];
        self.editItem.title = NSLocalizedString(@"Edit", nil);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // check if the back button was pressed
    if (self.isMovingFromParentViewController) {
        [self.gallery cancelGetData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.workMode == editMode && self.selectedImages.count > 0) {
        [self.gallery addPhotos:self.selectedImages];
        self.selectedImages = [NSMutableArray array];
        [self reloadGalleryContent];
    }
}

- (void)showAlert:(NSNotification *)notification {
    
    NSError *error = [[notification userInfo] objectForKey:errorKey];
    
    UIAlertController *alertController = [[AlertManager defaultManager] showErrorAlertWithTitle:NSLocalizedString(@"Data loading failed", nil) andMessage:[error localizedDescription]];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Initialization

- (void)subscribeToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadItem:) name:fileDownloadComplite object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPreviews:) name:PhotosInformationReceived object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlert:)
                                                 name:dataFetchError object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlert:)
                                                 name:dataParsingFailed object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadGalleryContent {
    if (!self.gallery) {
        //self.gallery = [[Gallery alloc] initWithDictionary:@"72157704531735241"];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.gallery reloadContent];
    });
}

#pragma mark - Work with view

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController *destinationViewController = [segue destinationViewController];
    
    if ([destinationViewController isKindOfClass:[PhotoViewController class]] &&
        [sender isKindOfClass:[UICollectionViewCell class]]) {
        
        PhotoViewController *photoViewController = (PhotoViewController *)destinationViewController;
        
        photoViewController.gallery = self.gallery;    
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
    if (self.workMode == editMode) {
        return NO;
    }
    return YES;
}

- (void)showPreviews:(NSNotification *) notification {
    [self.galleryCollectionView setHidden:NO];
    [self.activityIndicator stopAnimating];
    [self.galleryCollectionView reloadData];
}


- (void)reloadItem:(NSNotification *)notification {
    NSNumber * number = [[notification object] valueForKey:photoIndex];
    NSInteger index = [number integerValue];
    
    NSLog(@"reloadItem: for item - %ld", (long)index);
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    [self.collectionViewDataSource collectionView:self.galleryCollectionView
                                                reloadItemAtIndex:indexPath];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.workMode != editMode) {
        self.gallery.selectedImageIndex = [indexPath indexAtPosition:1];
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
    
    if (self.selectedCellsIndexPath.count > 0) {
        [self.trash setEnabled:YES];
    } else {
        [self.trash setEnabled:NO];
    }
}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    self.gallery.selectedImageIndex = [indexPath indexAtPosition:1];
//}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if ([scrollView isBottomReached]) {
        CGFloat width = self.galleryCollectionView.frame.size.width;
        [[self getFooter] showWithWight:width];
        [self.gallery getAdditionalContent];
    }
}

- (FooterCollectionReusableView *)getFooter {
   UICollectionReusableView *footer = [self.galleryCollectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathWithIndex:0]];

    return (FooterCollectionReusableView *)footer;
}

- (GalleryHeaderCollectionReusableView *)getHeader {
    UICollectionReusableView *header = [self.galleryCollectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathWithIndex:0]];
    
    return (GalleryHeaderCollectionReusableView *)header;
}

#pragma mark - User actions

- (IBAction)addPhotosToGallery:(id)sender {
    UIStoryboard *nextStoryBoard = [UIStoryboard storyboardWithName:@"AddGallery" bundle:nil];
    AddPhotosToGalleryViewController *addPhotocVC = [nextStoryBoard instantiateViewControllerWithIdentifier:@"AddPhotosVC"];
    
    addPhotocVC.selectedImages = self.selectedImages;
    [self.navigationController pushViewController:addPhotocVC animated:YES];
}

- (IBAction)editPressed:(id)sender {
    if (self.workMode == readMode) {
        self.workMode = editMode;
        [self.toolBar setHidden:NO];
        [self.addButton setHidden:NO];
        self.editItem.title = NSLocalizedString(@"Done", nil);
    }
    else {
        self.workMode = readMode;
        [self.toolBar setHidden:YES];
        [self.addButton setHidden:YES];
        self.editItem.title = NSLocalizedString(@"Edit", nil);
    }
}

- (IBAction)deleteSelectedItems:(id)sender {
    if (self.selectedCellsIndexPath > 0) {
        NSMutableArray *deleteIndexes = [NSMutableArray array];
        for (NSIndexPath *indexPath in self.selectedCellsIndexPath) {
            NSNumber *index = [NSNumber numberWithInteger:[indexPath indexAtPosition:1]];
            [deleteIndexes addObject:index];
        }
        [self.gallery deletePhotosByIndexes:deleteIndexes];
    }
    
    [self reloadGalleryContent];
    self.selectedCellsIndexPath = [NSMutableSet set];
    [self.trash setEnabled:NO];
}

- (IBAction)editingDone:(id)sender {
    self.workMode = readMode;
    [self.toolBar setHidden:YES];
    [self.addButton setHidden:YES];
    self.editItem.title = NSLocalizedString(@"Edit", nil);
}

@end

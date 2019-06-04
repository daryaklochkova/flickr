//
//  PhotoViewController.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 08/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "PhotoViewController.h"
#import "GalleryCollectionViewDataSource.h"
#import "UIScrollView.h"
#import "PhotoCollectionViewCell.h"

@interface PhotoViewController () <UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UICollectionView *auxiliaryCollectionView;
@property (strong, nonatomic) GalleryCollectionViewDataSource *auxiliaryDataSourceDelegate;
@property (strong, nonatomic) GalleryCollectionViewDataSource *mainDataSourceDelegate;
@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;
@property (strong, nonatomic) NSIndexPath *currentItemIndexPath;

@end


@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setSwipes];
    [self setTapGestureRecognizer];
    [self initiateCollectionViews];
    [self subsctibeToNotifications];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>) self.mainCollectionView.delegate;
    
    CGSize cellSize = [delegate collectionView:self.mainCollectionView layout:self.mainCollectionView.collectionViewLayout sizeForItemAtIndexPath:self.currentItemIndexPath];
    
    id<PhotoCell> photoCell = (id<PhotoCell>)[self.mainCollectionView cellForItemAtIndexPath:self.currentItemIndexPath];
    [photoCell configureViewWithSize:cellSize];
    
    NSInteger index = self.gallery.selectedImageIndex;
    self.currentItemIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    [self.auxiliaryCollectionView scrollToItemAtIndexPath:self.currentItemIndexPath
                         atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                         animated:NO];
    
    [self.mainCollectionView scrollToItemAtIndexPath:self.currentItemIndexPath
                        atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                        animated:NO];
}

#pragma mark - Initialization

- (void)initiateCollectionViews {
    self.auxiliaryDataSourceDelegate = [[GalleryCollectionViewDataSource alloc]
                                        initWithGallery:self.gallery andCellReuseIdentifier:@"PhotoCell"];
    
    self.mainDataSourceDelegate = [[GalleryCollectionViewDataSource alloc]
                                   initWithGallery:self.gallery andCellReuseIdentifier:@"MainPhotoCell"];
    
    self.auxiliaryCollectionView.dataSource = self.auxiliaryDataSourceDelegate;
    self.mainCollectionView.dataSource = self.mainDataSourceDelegate;
}

- (void)subsctibeToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadItem:) name:fileDownloadComplite object:nil];
}

#pragma mark - Set gestures

- (void)setTapGestureRecognizer {
    UITapGestureRecognizer *onceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnceTapRecognizer:)];
    onceTap.numberOfTapsRequired = 1;
    [self.mainCollectionView addGestureRecognizer:onceTap];
}

- (void)setSwipes {
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    
    [self.mainCollectionView addGestureRecognizer:swipeLeft];
    [self.mainCollectionView addGestureRecognizer:swipeRight];
    [self.mainCollectionView addGestureRecognizer:swipeUp];
    [self.mainCollectionView addGestureRecognizer:swipeDown];
}


#pragma mark - Gesture handlers

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if ((swipe.direction & UISwipeGestureRecognizerDirectionUp) ||
        (swipe.direction & UISwipeGestureRecognizerDirectionDown))
    {
        [self.navigationController popViewControllerAnimated:NO];
    }
    
    if (swipe.direction & UISwipeGestureRecognizerDirectionLeft){
        [self showPhoto:[self.gallery nextPhotoIndex]];
    }
    
    if (swipe.direction & UISwipeGestureRecognizerDirectionRight){
        [self showPhoto:[self.gallery previousPhotoIndex]];
    }
}


- (void)handleOnceTapRecognizer:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.auxiliaryCollectionView isHidden]){
            [self.auxiliaryCollectionView setHidden:NO];
        }
        else {
            [self.auxiliaryCollectionView setHidden:YES];
        }
    }
}


#pragma mark - Work with views

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    id<PhotoCell> cell = [self getCurrentMainPhotoCell];
    [cell configureViewWithSize:self.mainCollectionView.frame.size];
}

- (void)reloadItem:(NSNotification *)notification {
    
    NSNumber * number = [[notification object] valueForKey:photoIndex];
    NSInteger index = [number integerValue];
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    [self.auxiliaryDataSourceDelegate collectionView:self.auxiliaryCollectionView
                                    reloadItemAtIndex:indexPath];
    [self.mainDataSourceDelegate collectionView:self.mainCollectionView
                                    reloadItemAtIndex:indexPath];
}

- (void)showPhoto:(NSInteger)index {
    
    self.currentItemIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    [self.mainCollectionView scrollToItemAtIndexPath:self.currentItemIndexPath  atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    [self.auxiliaryCollectionView scrollToItemAtIndexPath:self.currentItemIndexPath  atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (id <PhotoCell>)getCurrentMainPhotoCell {
    UICollectionViewCell *cell = [self.mainCollectionView cellForItemAtIndexPath:self.currentItemIndexPath];
    
    if ([cell conformsToProtocol:@protocol(PhotoCell)]) {
        return (id <PhotoCell>) cell;
    }
    
    return nil;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.gallery.selectedImageIndex = [indexPath indexAtPosition:1];
    self.currentItemIndexPath = indexPath;
    
    [self.mainCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    [self.auxiliaryCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.mainCollectionView]) {
        return collectionView.frame.size;
    }
    
    return [(UICollectionViewFlowLayout *)collectionViewLayout itemSize];
}

@end

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

@interface PhotoViewController () <UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) GalleryCollectionViewDataSource *collectionViewDataSource;

@end


@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadImageView];
    [self setSwipes];
    [self setTapGestureRecognizer];
    
    self.collectionViewDataSource = [[GalleryCollectionViewDataSource alloc] initWithGallery:self.gallery];
    self.collectionView.dataSource = self.collectionViewDataSource;
}


#pragma mark - Set gestures

- (void)setTapGestureRecognizer {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapRecognizer:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *onceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnceTapRecognizer:)];
    onceTap.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer:onceTap];
}


- (void)setSwipes{
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
    [self.view addGestureRecognizer:swipeUp];
    [self.view addGestureRecognizer:swipeDown];
}


#pragma mark - Gesture handlers

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe{
    
    if ((swipe.direction & UISwipeGestureRecognizerDirectionUp) ||
        (swipe.direction & UISwipeGestureRecognizerDirectionDown))
    {
        [self.navigationController popViewControllerAnimated:NO];
    }
    
    if (swipe.direction & UISwipeGestureRecognizerDirectionLeft){
        [self showPhoto:[self.gallery nextPhoto]];
    }
    
    if (swipe.direction & UISwipeGestureRecognizerDirectionRight){
        [self showPhoto:[self.gallery previousPhoto]];
    }
}


- (void)handleDoubleTapRecognizer:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if(self.scrollView.zoomScale > self.scrollView.minimumZoomScale){
            [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:NO];
        }
        else{
            CGPoint location = [sender locationInView:self.scrollView];
            [self.scrollView zoomToPoint:location withScale:self.scrollView.maximumZoomScale animated:NO];
        }
    }
}

- (void)handleOnceTapRecognizer:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.collectionView isHidden]){
            [self.collectionView setHidden:NO];
        } else {
            [self.collectionView setHidden:YES];
        }
    }
}


#pragma mark - Work with views

- (void)showPhoto:(Photo *)photo {
    UIImage *image = [UIImage imageWithContentsOfFile:[self.gallery getLocalPathForPhoto:photo]];

    if (image){
        self.image = image;
        [self reloadImageView];
    } else {
        [self showActivityView];
    }
}

- (void)showActivityView{
    [self.activityIndicator setHidden:NO];
    [self.imageView setHidden:YES];
    [self.activityIndicator startAnimating];
}

- (void)showImageView{
    [self.activityIndicator setHidden:YES];
    [self.imageView setHidden:NO];
}

- (void)reloadImageView{
    
    if (!self.image){
        self.image = [UIImage imageNamed:@"flickrTest"];
    }
    
    self.imageView.image = self.image;
    [self showImageView];
}


#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    self.gallery.selectedImageIndex = [indexPath indexAtPosition:1];
    [self showPhoto:[self.gallery currentPhoto]];
}

@end

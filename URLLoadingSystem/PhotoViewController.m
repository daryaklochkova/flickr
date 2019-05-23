//
//  PhotoViewController.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 08/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "PhotoViewController.h"
#import "GalleryCollectionViewDataSource.h"

@interface PhotoViewController () <UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) GalleryCollectionViewDataSource *collectionViewDataSource;

@end

@interface UIScrollView (ZoomToPoint)
- (void)zoomToPoint:(CGPoint)zoomPoint withScale: (CGFloat)scale animated: (BOOL)animated;
@end

@implementation UIScrollView (ZoomToPoint)
- (void)zoomToPoint:(CGPoint)zoomPoint withScale: (CGFloat)scale animated: (BOOL)animated
{
    //Normalize current content size back to content scale of 1.0f
    CGSize contentSize;
    contentSize.width = (self.contentSize.width / self.zoomScale);
    contentSize.height = (self.contentSize.height / self.zoomScale);
    
    //translate the zoom point to relative to the content rect
    zoomPoint.x = (zoomPoint.x / self.bounds.size.width) * contentSize.width;
    zoomPoint.y = (zoomPoint.y / self.bounds.size.height) * contentSize.height;
    
    //derive the size of the region to zoom to
    CGSize zoomSize;
    zoomSize.width = self.bounds.size.width / scale;
    zoomSize.height = self.bounds.size.height / scale;
    
    //offset the zoom rect so the actual zoom point is in the middle of the rectangle
    CGRect zoomRect;
    zoomRect.origin.x = zoomPoint.x - zoomSize.width / 2.0f;
    zoomRect.origin.y = zoomPoint.y - zoomSize.height / 2.0f;
    zoomRect.size.width = zoomSize.width;
    zoomRect.size.height = zoomSize.height;
    
    //apply the resize
    [self zoomToRect: zoomRect animated: animated];
}

@end


@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadImageView];
    [self setSwipes];
    [self setTapGestureRecognizer];
    
    self.collectionViewDataSource = [[GalleryCollectionViewDataSource alloc] initWithGallery:self.gallery];
    self.collectionView.dataSource = self.collectionViewDataSource;
    
    //[self.imageView becomeFirstResponder];
}


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


- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe{
    
    if ((swipe.direction & UISwipeGestureRecognizerDirectionUp) ||
         (swipe.direction & UISwipeGestureRecognizerDirectionDown))
    {
        [self dismissViewControllerAnimated:NO completion:nil];
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

- (void)reloadImageView{
    
    if (!self.image){
        self.image = [UIImage imageNamed:@"flickrTest"];
    }
    
    self.imageView.image = self.image;
    [self showImageView];
}

#pragma MARK - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    self.gallery.selectedImageIndex = [indexPath indexAtPosition:1];
    [self showPhoto:[self.gallery currentPhoto]];
}

@end

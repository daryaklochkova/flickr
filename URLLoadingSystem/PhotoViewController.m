//
//  PhotoViewController.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 08/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadImageView];
    [self setSwipes];
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

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if ((swipe.direction & UISwipeGestureRecognizerDirectionUp) ||
         (swipe.direction & UISwipeGestureRecognizerDirectionDown))
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }

    if (swipe.direction & UISwipeGestureRecognizerDirectionLeft){
        self.image = [UIImage imageWithContentsOfFile:[self.gallery nextImage]];
        [self reloadImageView];
    }
    
    if (swipe.direction & UISwipeGestureRecognizerDirectionRight){
        self.image = [UIImage imageWithContentsOfFile:[self.gallery previousImage]];
        [self reloadImageView];
    }
}

- (void)reloadImageView{
    self.imageView.image = self.image;
}

#pragma MARK - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

@end

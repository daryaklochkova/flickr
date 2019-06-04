//
//  MainPhotoCollectionViewCell.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 30/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "MainPhotoCollectionViewCell.h"
#import "UIScrollView.h"

@interface MainPhotoCollectionViewCell()
@property (strong, nonatomic) IBOutlet MainPhotoCollectionViewCell *cell;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation MainPhotoCollectionViewCell

@synthesize imageView;

#pragma mark - Init functions

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Initialization

- (void)commonInit {
    [[[NSBundle mainBundle] loadNibNamed:@"MainPhotoCell" owner:self options:nil] firstObject];
    [self addSubview:self.cell];

    self.scrollView.delegate = self;
    [self setTapGestureRecognizer];
}

- (void)configureViewWithSize:(CGSize)size {
    self.cell.frame = CGRectMake(0, 0, size.width, size.height);
    [self moveImage];
}

- (void)setImageToImageView:(UIImage *)image {
    self.imageView = [[UIImageView alloc] initWithImage:image];
    [self.scrollView addSubview:self.imageView];

    [self moveImage];
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    
    [self stopActivityIndicator];
}

- (void)moveImage {
    [self centerImage];
    [self setMaxMinZoomScaleForCurrentBounds];
}

#pragma mark - Prepare for reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    [self.activityIndicator stopAnimating];
}

#pragma mark - Found image coordinates and scale

- (void) setMaxMinZoomScaleForCurrentBounds {
    CGSize boundsSize = self.cell.bounds.size;
    CGSize imageSize = self.imageView.bounds.size;
    
    CGFloat xScale = boundsSize.width  / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    
    self.scrollView.maximumZoomScale = 3;
    self.scrollView.minimumZoomScale = MIN(xScale, yScale) - 0.001f;
}

- (void)centerImage {
    CGSize boundsSize = self.cell.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }

    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    
    self.imageView.frame = frameToCenter;
}

#pragma mark - Set gesture

- (void)setTapGestureRecognizer {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomToPoint:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTap];
}

#pragma mark - Handle double tap user action

- (void)zoomToPoint:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if(self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
            [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
        }
        else {
            CGPoint location = [sender locationInView:self.scrollView];
            [self.scrollView zoomToPoint:location withScale:self.scrollView.maximumZoomScale animated:YES];
        }
    }
}

#pragma mark - Actions with activity indicator

- (void)startActivityIndicator {
    [self.activityIndicator startAnimating];
    [self.imageView setHidden:YES];
}

- (void)stopActivityIndicator {
    [self.activityIndicator stopAnimating];
    [self.imageView setHidden:NO];
}

#pragma mark - UIScrollViewDelegate implementation

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerImage];
}



@end

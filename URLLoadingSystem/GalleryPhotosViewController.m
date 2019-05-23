//
//  GalleryPhotosViewController.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 08/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GalleryPhotosViewController.h"
#import "GalleryCollectionViewDataSource.h"

@interface GalleryPhotosViewController()

@property (weak, nonatomic) IBOutlet UICollectionView *galleryCollectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UINavigationItem *galleryTitle;

@property (strong, nonatomic) GalleryCollectionViewDataSource *collectionViewDataSource;

@end


@implementation GalleryPhotosViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createGallery];
    [self subscribeToNotifications];
    //[self.galleryCollectionView setHidden:YES];
    
    self.collectionViewDataSource = [[GalleryCollectionViewDataSource alloc] initWithGallery:self.gallery];
    self.galleryCollectionView.dataSource = self.collectionViewDataSource;
}


- (void)createGallery{
    if (!self.gallery) {
        self.gallery = [[Gallery alloc] initWithGalleryID:@"72157704531735241"];
    }
    
    self.galleryTitle.title = self.gallery.title;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.gallery updateContent];
    });
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // check if the back button was pressed
    if (self.isMovingFromParentViewController) {
        [self.gallery cancelGetData];
    }
}
        

- (void)subscribeToNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadItem:) name:fileDownloadComplite object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPreviews:) name:PhotosInformationReceived object:nil];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController *destinationViewController = [segue destinationViewController];
    
    if ([destinationViewController isKindOfClass:[PhotoViewController class]]){
    
        PhotoViewController *photoViewController = (PhotoViewController *)destinationViewController;
        if ([sender isKindOfClass:[UICollectionViewCell class]]){
            UICollectionViewCell *cell = (UICollectionViewCell *)sender;
            UIImageView *cellImageView = (UIImageView *)cell.backgroundView;
            if (cellImageView){
                photoViewController.image = cellImageView.image;
                photoViewController.gallery = self.gallery;
            }    
        }
    }
}

- (void)showPreviews:(NSNotification *) notification{
    [self.galleryCollectionView setHidden:NO];
    [self.activityIndicator stopAnimating];
    [self.galleryCollectionView reloadData];
}

- (void)reloadItem:(NSNotification *) notification{
    NSNumber * number = [[notification object] valueForKey:photoIndex];
    NSInteger index = [number integerValue];
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    [self.collectionViewDataSource collectionView:self.galleryCollectionView
                                                reloadItemAtIndex:indexPath];

}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    self.gallery.selectedImageIndex = [indexPath indexAtPosition:1];
}

@end

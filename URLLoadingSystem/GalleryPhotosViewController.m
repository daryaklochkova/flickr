//
//  GalleryPhotosViewController.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 08/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "GalleryPhotosViewController.h"

@interface GalleryPhotosViewController()

@property (weak, nonatomic) IBOutlet UICollectionView *galleryCollectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UINavigationItem *galleryTitle;

@end


@implementation GalleryPhotosViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createGallery];
    [self subscribeToNotifications];
    [self.galleryCollectionView setHidden:YES];
}


- (void)createGallery{
    if (!self.gallery) {
        self.gallery = [[Gallery alloc] initWithGalleryID:@"72157704531735241"];
    }
    
    self.galleryTitle.title = self.gallery.title;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.gallery getPhotosUsing:[[DataProvider alloc] initWithParser:[[JSONParser alloc] init]]];
    });
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

#pragma mark - update Collection view

- (void)showPreviews:(NSNotification *) notification{
    [self.galleryCollectionView setHidden:NO];
    [self.activityIndicator stopAnimating];
    [self.galleryCollectionView reloadData];
}

- (void)reloadItem:(NSNotification *) notification{
    NSNumber * number = [[notification object] valueForKey:photoIndex];
    NSInteger index = [number integerValue];
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    UICollectionViewCell *cell = [self.galleryCollectionView cellForItemAtIndexPath:indexPath];
    
    if (cell){
        Photo *photo = [self.gallery.photos objectAtIndex:[indexPath indexAtPosition:1]];
        [self setPhoto:photo toCell:cell];
    }
}


- (BOOL)setPhoto:(Photo *) photo toCell:(UICollectionViewCell *) cell {
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[self.gallery getLocalPathForPhoto:photo]];
    
    if (image) {
        cell.backgroundView = [[UIImageView alloc] initWithImage:image];
        cell.userInteractionEnabled = YES;
        return YES;
    }
    return NO;
}

- (void)setActivityIndicatorToCell:(UICollectionViewCell *) cell{
    UIActivityIndicatorView * downloadActivityIndicator = [[UIActivityIndicatorView alloc] init];

    downloadActivityIndicator.backgroundColor = [UIColor grayColor];
    [downloadActivityIndicator startAnimating];

    cell.backgroundView = downloadActivityIndicator;
    cell.userInteractionEnabled = NO;
}


#pragma mark - UICollectionViewDataSource

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    cell.layer.cornerRadius = 10;
    cell.layer.masksToBounds = true;
    
    Photo *photo = [self.gallery.photos objectAtIndex:[indexPath indexAtPosition:1]];
    [self setPhoto:photo toCell:cell];
    
    if ([self setPhoto:photo toCell:cell] == NO){
        [self setActivityIndicatorToCell:cell];
    }
    
    return cell;
}


- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.gallery getPhotosCount];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    self.gallery.selectedImageIndex = [indexPath indexAtPosition:1];
}

@end

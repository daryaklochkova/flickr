//
//  XMLParserGetPhotoFromGallery.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 07/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "Gallery.h"

@interface Gallery()
@property (assign, nonatomic) BOOL isUpdateCanceld;

@end

@implementation Gallery

NSNotificationName const GalleryWasUpdateNotification = @"GalleryWasUpdateNotification";
NSNotificationName const PhotosInformationReceived = @"PhotosInformationReceived";

NSNotificationName const fileDownloadComplite = @"fileDownloadComplite";
NSString * const locationKey = @"locationKey";
NSString * const photoIndex = @"photoIndex";



- (instancetype)initWithGalleryID:(NSString *) galleryID{
    self = [super init];
    
    if (self) {
        _galleryID = galleryID;
        _folderPath = [self createGalleryFolder];
        self.currentPage = 0;
        self.title = [[NSString alloc] init];
        self.isUpdateCanceld = NO;
    }
    
    return self;
}


- (void)setDataProvider:(id<DataProviderProtocol>)dataProvider{
    if (self.dataProvider){
       [self cancelGetData];
    }
    
    _dataProvider = dataProvider;
}


- (NSString *)nextImage{
    
    NSInteger newImageIndex = self.selectedImageIndex + 1;
    if (newImageIndex  < self.photos.count){
        self.selectedImageIndex = newImageIndex;
    }
    
    Photo *selectedPhoto = [self.photos objectAtIndex:self.selectedImageIndex];
    return [self getLocalPathForPhoto:selectedPhoto];
}


- (NSString *)previousImage{
    
    NSInteger newImageIndex = self.selectedImageIndex - 1;
    if (newImageIndex >= 0){
        self.selectedImageIndex = newImageIndex;
    }
    
    Photo *selectedPhoto = [self.photos objectAtIndex:self.selectedImageIndex];
    return [self getLocalPathForPhoto:selectedPhoto];
}


- (NSInteger)getPhotosCount{
    return self.photos.count;
}


- (NSString *)getLocalPathForPhoto:(Photo *)photo{
    NSString *localPath = [self.folderPath stringByAppendingPathComponent:photo.name];
    return localPath;
}


- (NSString *)getLocalPathForPrimaryPhoto{
    return [self getLocalPathForPhoto:self.primaryPhoto];
}


- (NSString *)createGalleryFolder{
 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    
    NSString *assetsAndGalleryID = [NSString stringWithFormat:@"Assets/%@", self.galleryID];
    NSString *assetsDir = [cachesDir stringByAppendingPathComponent:assetsAndGalleryID];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:assetsDir
                                    withIntermediateDirectories:YES
                                    attributes:nil
                                    error:&error];
    return assetsDir;
}


- (void)updateContent{
   [self cancelGetData];
    
    @synchronized (self) {
        self.isUpdateCanceld = NO;
    }
    
    [self.dataProvider getPhotosForGallery:self.galleryID use:^(NSArray * _Nullable result) {
        @synchronized (self) {
            self.photos = result;
        }
        [self allElementsParsed];
    }];
}


- (void)cancelGetData{
    @synchronized (self) {
        self.isUpdateCanceld = YES;
    }
    
    for (Photo *photo in self.photos) {
        [self.dataProvider cancelDownloadTasksByURL:photo.remoteURL];
    }
}


- (void)allElementsParsed{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PhotosInformationReceived object:nil];
    });
    
    for (NSInteger i = 0; i < self.photos.count; i++) {
        if (!self.isUpdateCanceld){
            Photo * photo = [self.photos objectAtIndex:i];
            
            NSDictionary *dictionary = @{locationKey:[self getLocalPathForPhoto:photo], photoIndex:[NSNumber numberWithInteger:i]};
            
            NSNotification *fileDownloadCompliteNotification = [NSNotification notificationWithName:fileDownloadComplite object:dictionary];
            
            [self getPhoto:photo sucsessNotification:fileDownloadCompliteNotification];
        }
    }
}


- (void)getPhoto:(Photo *) photo sucsessNotification:(NSNotification *) notification{
    
    NSURL *fileURL = [NSURL fileURLWithPath:[self getLocalPathForPhoto:photo]];
    NSURL *remoteURL = [photo remoteURL];
    
    [self.dataProvider getFileFrom:remoteURL saveIn:fileURL sucsessNotification:notification];
}


@end

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
@property (strong, nonatomic) NSMutableArray<Photo *> *mutablePhotos;

@end

@implementation Gallery

NSNotificationName const GalleryWasUpdateNotification = @"GalleryWasUpdateNotification";
NSNotificationName const PhotosInformationReceived = @"PhotosInformationReceived";

NSNotificationName const fileDownloadComplite = @"fileDownloadComplite";
NSString * const locationKey = @"locationKey";
NSString * const photoIndex = @"photoIndex";

- (instancetype)initWithDictionary:(NSDictionary *) dictionary andOwnerUser:(User *) user {
    self = [super init];
    
    if (self) {
        _galleryID = [dictionary objectForKey:galleryIDArgumentName];
        _folderPath = [self createGalleryFolder:user.userFolder];
        _owner = user;
        self.currentPage = 0;
        self.title = [dictionary objectForKey:titleArgumentName];
        self.galleryDescription = [dictionary objectForKey:descriptionArgumentName];
        self.primaryPhoto = [[Photo alloc] initPrimaryPhotoWithDictionary:dictionary];
        self.isUpdateCanceld = NO;
        self.mutablePhotos = [NSMutableArray array];
    }
    
    return self;
}

- (void)setDataProvider:(id<PhotoProviderProtocol>)dataProvider{
    if (self.dataProvider){
        [self cancelGetData];
    }
    
    _dataProvider = dataProvider;
}

#pragma mark - Navigation

- (Photo *)nextPhoto {
    Photo *selectedPhoto = [self.photos objectAtIndex:[self nextPhotoIndex]];
    return selectedPhoto;
}


- (Photo *)previousPhoto {
    Photo *selectedPhoto = [self.photos objectAtIndex:[self previousPhotoIndex]];
    return selectedPhoto;
}

- (Photo *)currentPhoto {
    Photo *selectedPhoto = [self.photos objectAtIndex:self.selectedImageIndex];
    return selectedPhoto;
}

- (NSInteger)getPhotosCount{
    return self.photos.count;
}

- (NSInteger)nextPhotoIndex {
    
    NSInteger newImageIndex = self.selectedImageIndex + 1;
    if (newImageIndex  < self.photos.count){
        self.selectedImageIndex = newImageIndex;
    }
    
    return self.selectedImageIndex;
}


- (NSInteger)previousPhotoIndex {
    
    NSInteger newImageIndex = self.selectedImageIndex - 1;
    if (newImageIndex >= 0){
        self.selectedImageIndex = newImageIndex;
    }
    
    return self.selectedImageIndex;
}

#pragma mark - File manager navigation

- (NSString *)getLocalPathForPhoto:(Photo *)photo{
    NSString *localPath = [self.folderPath stringByAppendingPathComponent:photo.name];
    return localPath;
}


- (NSString *)getLocalPathForPrimaryPhoto{
    return [self getLocalPathForPhoto:self.primaryPhoto];
}


- (NSString *)createGalleryFolder:(NSString *)rootFolder {
    
    NSString *assetsAndGalleryID = [NSString stringWithFormat:@"Assets/%@", self.galleryID];
    
    NSString *assetsDir = [rootFolder stringByAppendingPathComponent:assetsAndGalleryID];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:assetsDir
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    return assetsDir;
}


#pragma mark - Update content

- (void)reloadContent {
    //[self cancelGetData];
    
    @synchronized (self) {
        self.isUpdateCanceld = NO;
        self.mutablePhotos = [NSMutableArray array];
    }
    
    [self.dataProvider getPhotosForGallery:self.galleryID use:[self getResponseHandler]];
}


- (void)addPhotos:(NSArray<UIImage *> *)photos {
    if (photos.count > 0) {
    [self.dataProvider savePhotos:photos forGalleryID:self.galleryID byPath:self.folderPath];
    }
}


- (void)deletePhotosByIndexes:(NSArray<NSNumber *> *)indexes {
    
    NSMutableSet<NSString *> *deletedPhotosNames = [NSMutableSet set];
    
    for (NSNumber *index in indexes) {
        Photo *deletedPhoto = [self.photos objectAtIndex:index.integerValue];
        NSString *deletedName = deletedPhoto.name;
        [deletedPhotosNames addObject:deletedName];
    }
    
    [self.dataProvider deletePhotos:deletedPhotosNames inGallery:self.galleryID byGalleryPath:self.folderPath];
}

- (void)addPrimaryPhoto:(UIImage *)cover {
    [self.dataProvider savePrimaryPhoto:cover forGalleryID:self.galleryID byPath:self.folderPath];
}


- (void)getAdditionalContent {
    if ([self.dataProvider respondsToSelector:@selector(getAdditionalPhotosForGallery:use:)]) {
        [self.dataProvider getAdditionalPhotosForGallery:self.galleryID use:[self getResponseHandler]];
    }
}


- (ReturnResult)getResponseHandler {
    __weak typeof(self) weakSelf = self;
    
    ReturnResult block = ^(NSArray * _Nullable result) {
        __strong typeof(self) strongSelf = weakSelf;
        @synchronized (strongSelf) {
            [strongSelf.mutablePhotos addObjectsFromArray:result];
            strongSelf.photos = strongSelf.mutablePhotos;
        }
        [strongSelf elementsParsed:strongSelf.photos];
    };
    
    return block;
}


- (void)cancelGetData {
    @synchronized (self) {
        self.isUpdateCanceld = YES;
    }
    
    for (Photo *photo in self.photos) {
        if ([self.dataProvider respondsToSelector:@selector(cancelTasksByURL:)]) {
            [self.dataProvider cancelTasksByURL:photo.remoteURL];
        }
    }
}


- (void)elementsParsed:(NSArray<Photo *> *)photos {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PhotosInformationReceived object:nil];
    });
    
    for (NSInteger i = 0; i < photos.count; i++) {
        if (!self.isUpdateCanceld){
            Photo * photo = [photos objectAtIndex:i];
            
            NSDictionary *dictionary = @{locationKey:[self getLocalPathForPhoto:photo], photoIndex:[NSNumber numberWithInteger:i]};
            
            NSNotification *fileDownloadCompliteNotification = [NSNotification notificationWithName:fileDownloadComplite object:dictionary];
            
            [self getPhoto:photo sucsessNotification:fileDownloadCompliteNotification];
        }
    }
}


- (void)getPhoto:(Photo *) photo sucsessNotification:(NSNotification *)notification {
    
    if ([self.dataProvider respondsToSelector:@selector(getFileFrom:saveIn:sucsessNotification:)]) {
        
        NSURL *fileURL = [NSURL fileURLWithPath:[self getLocalPathForPhoto:photo]];
        NSURL *remoteURL = [photo remoteURL];
        
        [self.dataProvider getFileFrom:remoteURL saveIn:fileURL sucsessNotification:notification];
    }
}



@end

//
//  LocalPhotosProvider.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 10/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "LocalPhotosProvider.h"
#import "NSUserDefaults.h"
#import "Photo.h"

const NSNotificationName PhotosInGalleryWasChanged = @"PhotosInGalleryWasChanged";
const NSString *changedGalleryKey = @"PhotosInGalleryWasChangedKey";

@interface LocalPhotosProvider()
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@end

@implementation LocalPhotosProvider 

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)getFileFrom:(nonnull NSURL *)remoteURL
             saveIn:(nonnull NSURL *)localFileURL
sucsessNotification:(nonnull NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    });
}

- (void)getPhotosForGallery:(NSString * _Nullable)galleryID
                        use:(ReturnPhotosResult _Nullable)completionHandler {
    NSArray *photosInfo = [self.userDefaults getPhotoInfoArrayForGallery:galleryID];
    NSMutableArray *photos = [NSMutableArray array];

    for (NSString *photoID in photosInfo) {
        Photo *photo = [[Photo alloc] initWithDictionary:@{@"id":photoID}];
        [photos addObject:photo];
    }
    completionHandler(photos);
}

- (void)sendPhotosWasChangeInGallery:(NSString *)galleryID {
    
    NSDictionary *info = @{
                           changedGalleryKey:galleryID
                           };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:PhotosInGalleryWasChanged
         object:info];
    });
}

- (void)savePhotos:(nonnull NSArray<UIImage *> *)images
      forGalleryID:(nonnull NSString *)galleryID
            byPath:(nonnull NSString *)path {
    
    NSDictionary *targetInfo = [self.userDefaults getInfoForGallery:galleryID];
    NSMutableDictionary *mutableInfo = targetInfo.mutableCopy;
    
    NSArray *photos = targetInfo[@"photos"];
    
    NSString *lastPhotoName = [photos lastObject];
    int lastNumber = [[lastPhotoName componentsSeparatedByString:@"_"][1] intValue];
    NSMutableArray *matablePhotos = [NSMutableArray arrayWithArray:photos];
    
    for (int i = 0; i < images.count; i++) {
        UIImage *image = images[i];
        NSString *fileName = [NSString stringWithFormat:@"%@_%ld", galleryID, (long)(i + lastNumber + 1)];
        [self saveImage:image named:fileName byPath:path];
        [matablePhotos addObject:fileName];
    }
    
    [mutableInfo setValue:matablePhotos forKey:@"photos"];
    [self.userDefaults resaveInfoForGallery:galleryID newInfo:mutableInfo];
    
    [self sendPhotosWasChangeInGallery:galleryID];
}


- (void)savePrimaryPhoto:(UIImage *)image
            forGalleryID:(NSString *)galleryID
                  byPath:(NSString *)path {
    NSDictionary *targetInfo = [self.userDefaults getInfoForGallery:galleryID];
    NSMutableDictionary *mutableInfo = targetInfo.mutableCopy;
    
    NSString *fileName = [NSString stringWithFormat:@"primary_%@", galleryID];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    [self saveImage:image named:fileName byPath:path];
    [mutableInfo setValue:fileName forKey:[primaryPhotoIdArgumentName copy]];
    [self.userDefaults resaveInfoForGallery:galleryID newInfo:mutableInfo];
    
    [self sendPhotosWasChangeInGallery:galleryID];
}


- (void)saveImage:(UIImage *)image named:(NSString *)fileName byPath:(NSString *)path {
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
}

- (void)deletePhotos:(NSSet<NSString *> *)deletedPhotoNames
          inGallery:(NSString *)galleryID
      byGalleryPath:(NSString *)path {
    NSArray *photosInfo = [self.userDefaults getPhotoInfoArrayForGallery:galleryID];
    
    NSMutableArray *newPhotos = [NSMutableArray array];
    for (NSString *photoName in photosInfo) {
        if ([deletedPhotoNames containsObject:photoName]) {
            NSString *filePath = [path stringByAppendingPathComponent:photoName];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        else {
            [newPhotos addObject:photoName];
        }
    }
    
    NSMutableDictionary *newGalleryInfo = [self.userDefaults getInfoForGallery:galleryID].mutableCopy;
    [newGalleryInfo setValue:newPhotos forKey:@"photos"];
    [self.userDefaults resaveInfoForGallery:galleryID newInfo:newGalleryInfo];
    
    [self sendPhotosWasChangeInGallery:galleryID];
}



@end

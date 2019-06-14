//
//  LocalPhotosProvider.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 10/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "LocalPhotosProvider.h"


@implementation LocalPhotosProvider 

- (void)getFileFrom:(nonnull NSURL *)remoteURL
             saveIn:(nonnull NSURL *)localFileURL
sucsessNotification:(nonnull NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    });
}

- (void)getPhotosForGallery:(NSString * _Nullable)galleryID
                        use:(ReturnPhotosResult _Nullable)completionHandler {
    NSArray *photosInfo = [self getPhotoInfoArrayForGallery:galleryID];
    NSMutableArray *photos = [NSMutableArray array];

    for (NSString *photoID in photosInfo) {
        Photo *photo = [[Photo alloc] initWithDictionary:@{@"id":photoID}];
        [photos addObject:photo];
    }
    completionHandler(photos);
}

- (NSArray *)getPhotoInfoArrayForGallery:(NSString *)galleryID {
    NSDictionary *targetGalleryInfo = [self getInfoForGallery:galleryID];
    return [targetGalleryInfo valueForKey:@"photos"];
}

- (void)savePhotos:(nonnull NSArray<UIImage *> *)images
      forGalleryID:(nonnull NSString *)galleryID
            byPath:(nonnull NSString *)path {
    
    NSDictionary *targetInfo = [self getInfoForGallery:galleryID];
    NSMutableDictionary *mutableInfo = targetInfo.mutableCopy;
    
    NSArray *photos = [targetInfo objectForKey:@"photos"];
    NSString *lastPhotoName = [photos lastObject];
    int lastNumber = [[lastPhotoName componentsSeparatedByString:@"_"][1] intValue];
    NSMutableArray *matablePhotos = [NSMutableArray arrayWithArray:photos];
    
    for (int i = 0; i < images.count; i++) {
        UIImage *image = [images objectAtIndex:i];
        NSString *fileName = [NSString stringWithFormat:@"%@_%ld", galleryID, (long)(i + lastNumber + 1)];
        [self saveImage:image named:fileName byPath:path];
        [matablePhotos addObject:fileName];
    }
    
    [mutableInfo setValue:matablePhotos forKey:@"photos"];
    [self resaveInfoForGallery:galleryID newInfo:mutableInfo];
}

- (void)savePrimaryPhoto:(UIImage *)image
            forGalleryID:(NSString *)galleryID
                  byPath:(NSString *)path {
    NSDictionary *targetInfo = [self getInfoForGallery:galleryID];
    NSMutableDictionary *mutableInfo = targetInfo.mutableCopy;
    
    NSString *fileName = [NSString stringWithFormat:@"primary_%@", galleryID];
    [self saveImage:image named:fileName byPath:path];
    [mutableInfo setValue:fileName forKey:[primaryPhotoIdArgumentName copy]];
    [self resaveInfoForGallery:galleryID newInfo:mutableInfo];
}

- (void)resaveInfoForGallery:(NSString *)galleryID
                     newInfo:(NSDictionary *)newGalleryInfo {
    NSArray *localGalleriesInfo = [self getLocalGalleriesInfo];
    
    NSMutableArray *newLocalGalleriesInfo = [NSMutableArray array];
    for (NSDictionary *galleryInfo in localGalleriesInfo) {
        NSString *tmpGalleryID = [galleryInfo objectForKey:galleryIDArgumentName];
        if ([tmpGalleryID isEqualToString:galleryID]) {
            [newLocalGalleriesInfo addObject:newGalleryInfo];
        }
        else {
            [newLocalGalleriesInfo addObject:galleryInfo];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:newLocalGalleriesInfo
                                              forKey:[LocalGalleriesKey copy]];
}

- (void)saveImage:(UIImage *)image named:(NSString *)fileName byPath:(NSString *)path {
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
}

- (NSDictionary *)getInfoForGallery:(NSString * _Nullable)galleryID {
    NSArray *localGalleriesInfo = [self getLocalGalleriesInfo];
    for (NSDictionary *galleryInfo in localGalleriesInfo) {
        NSString *tmpGalleryID = [galleryInfo objectForKey:galleryIDArgumentName];
        if ([tmpGalleryID isEqualToString:galleryID]) {
            return galleryInfo;
        }
    }
    return nil;
}

- (NSArray *)getLocalGalleriesInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:[LocalGalleriesKey copy]];
}

- (void)deletPhotos:(NSSet<NSString *> *)deletedPhotoNames
          inGallery:(NSString *)galleryID
      byGalleryPath:(NSString *)path {
    NSArray *photosInfo = [self getPhotoInfoArrayForGallery:galleryID];
    
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
    
    NSMutableDictionary *newGalleryInfo = [self getInfoForGallery:galleryID].mutableCopy;
    [newGalleryInfo setValue:newPhotos forKey:@"photos"];
    [self resaveInfoForGallery:galleryID newInfo:newGalleryInfo];
}



@end

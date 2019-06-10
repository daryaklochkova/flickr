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
    NSArray *localGalleriesInfo = [[NSUserDefaults standardUserDefaults] objectForKey:[LocalGalleriesKey copy]];
    
    NSDictionary *targetGalleryInfo;
    for (NSDictionary *galleryInfo in localGalleriesInfo) {
        NSString *currentGalleryID = [galleryInfo valueForKey:@"gallery_id"];
        if ([galleryID isEqualToString:currentGalleryID]) {
            targetGalleryInfo = galleryInfo;
            break;
        }
    }
    
    NSArray *photosInfo = [targetGalleryInfo valueForKey:@"photos"];
    NSMutableArray *photos = [NSMutableArray array];
    
    for (NSString *photoID in photosInfo) {
        Photo *photo = [[Photo alloc] initWithDictionary:@{@"id":photoID}];
        [photos addObject:photo];
    }
    
    completionHandler(photos);
}


@end

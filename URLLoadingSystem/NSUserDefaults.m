//
//  NSUserDefaults.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 17/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "NSUserDefaults.h"
#import "Constants.h"

@implementation NSUserDefaults(LocalGalleries)

- (NSArray *)getLocalGalleriesInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:[LocalGalleriesKey copy]];
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

- (NSArray *)getPhotoInfoArrayForGallery:(NSString *)galleryID {
    NSDictionary *targetGalleryInfo = [self getInfoForGallery:galleryID];
    return [targetGalleryInfo valueForKey:@"photos"];
}

- (void)saveGalleryInfoInUserDefaults:(NSMutableDictionary *)galleryInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *localGalleriesInfo = [userDefaults objectForKey:[LocalGalleriesKey copy]];
    
    if (localGalleriesInfo) {
        NSMutableArray *mutableGalleriesInfo = [NSMutableArray arrayWithArray:localGalleriesInfo];
        [mutableGalleriesInfo addObject:galleryInfo];
        [userDefaults setObject:mutableGalleriesInfo forKey:[LocalGalleriesKey copy]];
    }
    else {
        [userDefaults setObject:@[galleryInfo] forKey:[LocalGalleriesKey copy]];
    }
}

- (void)deleteGalleryInfoByID:(NSString *)galleryID {
    
    NSArray *localGalleriesInfo = [self getLocalGalleriesInfo];
    
    NSMutableArray *newLocalGalleriesInfo = [NSMutableArray array];
    
    for (NSDictionary *galleryInfo in localGalleriesInfo) {
        NSString *tmpGalleryID = [galleryInfo objectForKey:galleryIDArgumentName];
        if (![tmpGalleryID isEqualToString:galleryID]) {
            [newLocalGalleriesInfo addObject:galleryInfo];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:newLocalGalleriesInfo
                                              forKey:[LocalGalleriesKey copy]];
}

@end

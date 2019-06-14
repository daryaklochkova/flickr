//
//  LocalGalleriesListProvider.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 06/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "LocalGalleriesListProvider.h"

@implementation LocalGalleriesListProvider

- (void)getAdditionalGalleriesForUser:(NSString * _Nullable)userID use:(ReturnGalleriesResult _Nullable ) completionHandler {
    
}

- (void)getGalleriesForUser:(NSString *)userID use:(ReturnResult) completionHandler {
    NSArray *localGalleriesInfo = [[NSUserDefaults standardUserDefaults] objectForKey:[LocalGalleriesKey copy]];
    
    if (localGalleriesInfo) {
        completionHandler(localGalleriesInfo);
    }
}

- (void)saveGallery:(Gallery *)gallery {
    NSDictionary *galleryInfo = @{
                                  galleryIDArgumentName:gallery.galleryID,
                                  titleArgumentName:gallery.title,
                                  descriptionArgumentName:gallery.description,
                                  userIDArgumentName:gallery.owner.userID,
                                  @"photos":[NSMutableArray array]
                                  };
    
    [self saveGalleryInfoInUserDefaults:galleryInfo.mutableCopy];
}

- (NSString *)getNextGalleryId {
    NSArray *localGalleriesInfo = [[NSUserDefaults standardUserDefaults] objectForKey:[LocalGalleriesKey copy]];
    if (localGalleriesInfo) {
        return [NSString stringWithFormat:@"%lu",(unsigned long)localGalleriesInfo.count];
    } else {
        return @"0";
    }
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


@end

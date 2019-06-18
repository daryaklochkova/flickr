//
//  NSUserDefaults.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 17/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSUserDefaults(LocalGalleries)

- (NSArray *)getLocalGalleriesInfo;
- (NSArray *)getPhotoInfoArrayForGallery:(NSString *)galleryID;
- (NSDictionary *)getInfoForGallery:(NSString * _Nullable)galleryID;

- (void)saveGalleryInfoInUserDefaults:(NSMutableDictionary *)galleryInfo;
- (void)deleteGalleryInfoByID:(NSString *)galleryID;
- (void)resaveInfoForGallery:(NSString *)galleryID newInfo:(NSDictionary *)newGalleryInfo;

@end

NS_ASSUME_NONNULL_END

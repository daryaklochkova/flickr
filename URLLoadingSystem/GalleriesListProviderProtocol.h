//
//  GalleriesListProviderProtocol.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 06/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"
#import "Gallery.h"

extern const NSNotificationName _Nullable GalleriesInfoWasChanged;

NS_ASSUME_NONNULL_BEGIN

@protocol GalleriesListProviderProtocol <NSObject>

- (void)getAdditionalGalleriesForUser:(NSString * _Nullable)userID use:(ReturnGalleriesResult _Nullable ) completionHandler;
- (void)getGalleriesForUser:(NSString *)userID use:(ReturnResult) completionHandler;

- (void)deleteGalleries:(NSSet<NSString *> *)galleryIDs inFolder:(NSString *)path;

- (NSString *)getNextGalleryId;
- (void)saveGallery:(Gallery *)gallery;
- (void)updateGalleryInfo:(Gallery *)gallery;

@end


NS_ASSUME_NONNULL_END

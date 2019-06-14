//
//  PhotoProviderProtocol.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 06/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ResponseParser.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PhotoProviderProtocol <NSObject>

- (void)getPhotosForGallery:(NSString * _Nullable)galleryID use:(ReturnPhotosResult _Nullable) completionHandler;

- (void)savePhotos:(NSArray<UIImage *>*)images forGalleryID:(NSString *)galleryID byPath:(NSString *)path;
- (void)savePrimaryPhoto:(UIImage *)image forGalleryID:(NSString *)galleryID byPath:(NSString *)path;
- (void)deletPhotos:(NSSet<NSString *> *)deletedPhotoNames inGallery:(NSString *)galleryID byGalleryPath:(NSString *)path;


@optional
- (void)getAdditionalPhotosForGallery:(NSString *)galleryID use:(ReturnResult) completionHandler;

- (void)cancelTasksByURL:(NSURL *) url;
- (void)getFileFrom:(NSURL *) remoteURL saveIn:(NSURL *) localFileURL sucsessNotification:(NSNotification *) notification;

@end

NS_ASSUME_NONNULL_END

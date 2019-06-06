//
//  PhotoProviderProtocol.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 06/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PhotoProviderProtocol <NSObject>

- (void)getPhotosForGallery:(NSString * _Nullable)galleryID use:(ReturnPhotosResult _Nullable) completionHandler;
- (void)getAdditionalPhotosForGallery:(NSString *)galleryID use:(ReturnResult) completionHandler;

- (void)cancelTasksByURL:(NSURL *) url;
- (void)getFileFrom:(NSURL *) remoteURL saveIn:(NSURL *) localFileURL sucsessNotification:(NSNotification *) notification;

@end

NS_ASSUME_NONNULL_END
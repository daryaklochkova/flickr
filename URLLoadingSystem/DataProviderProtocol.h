//
//  DataProviderProtocol.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 20/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParserProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DataProviderProtocol <NSObject>

- (instancetype _Nullable )initWithParser:(id<Parser>_Nullable) parser;

- (void)getGalleriesForUser:(NSString * _Nullable)userID use:(ReturnResult _Nullable ) completionHandler;
- (void)getPhotosForGallery:(NSString * _Nullable)galleryID use:(ReturnResult _Nullable) completionHandler;
- (void)cancelDownloadTasksByURL:(NSURL *) url;
- (void)getFileFrom:(NSURL *) remoteURL saveIn:(NSURL *) localFileURL sucsessNotification:(NSNotification *) notification;

@end

NS_ASSUME_NONNULL_END

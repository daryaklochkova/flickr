//
//  XMLParserGetPhotoFromGallery.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 07/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkManager.h"
#import "Photo.h"
#import "GetPhotosFromGalleryRequest.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const fileDownloadComplite;
extern NSString * const locationKey;
extern NSString * const photoIndex;

extern NSNotificationName const GalleryWasUpdateNotification;
extern NSNotificationName const PhotosInformationReceived;

@interface Gallery : NSObject <NSXMLParserDelegate>

@property (strong, nonatomic) NSArray<Photo *> *photos;

@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) NSInteger selectedImageIndex;
@property (strong, nonatomic, readonly) NSString *galleryID;
@property (strong, nonatomic) Photo *primaryPhoto;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic, readonly) NSString *folderPath;

@property (strong, nonatomic, readonly) GetPhotosFromGalleryRequest *request;

- (void)getPhotos;
- (instancetype)initWithGalleryID:(NSString *) galleryID;
- (NSString *)nextImage;
- (NSString *)previousImage;
- (NSString *)getLocalPathForPhoto:(Photo *)photo;
- (NSString *)getLocalPathForPrimaryPhoto;
- (NSInteger)getPhotosCount;
- (void)downloadPhoto:(Photo *) photo sucsessNotification:(NSNotification *) notification;

@end

NS_ASSUME_NONNULL_END

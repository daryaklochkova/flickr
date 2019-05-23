//
//  XMLParserGetPhotoFromGallery.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 07/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"
#import "PhotoProvider.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const fileDownloadComplite;
extern NSString * const locationKey;
extern NSString * const photoIndex;

extern NSNotificationName const GalleryWasUpdateNotification;
extern NSNotificationName const PhotosInformationReceived;


@interface Gallery : NSObject 

@property (strong, nonatomic) NSArray<Photo *> *photos;
@property (strong, nonatomic) id<PhotoProviderProtocol> dataProvider;

@property (strong, nonatomic) Photo *primaryPhoto;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) NSInteger selectedImageIndex;
@property (strong, nonatomic, readonly) NSString *galleryID;
@property (strong, nonatomic, readonly) NSString *folderPath;

- (void)updateContent;
- (instancetype)initWithGalleryID:(NSString *) galleryID;

- (Photo *)nextPhoto;
- (Photo *)previousPhoto;
- (Photo *)currentPhoto;

- (NSString *)getLocalPathForPhoto:(Photo *)photo;
- (NSString *)getLocalPathForPrimaryPhoto;
- (NSInteger)getPhotosCount;
- (void)getPhoto:(Photo *) photo sucsessNotification:(NSNotification *) notification;
- (void)cancelGetData;

- (void)setDataProvider:(id<PhotoProviderProtocol>)dataProvider;
@end

NS_ASSUME_NONNULL_END

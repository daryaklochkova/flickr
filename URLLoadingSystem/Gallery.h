//
//  XMLParserGetPhotoFromGallery.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 07/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PhotoProvider.h"

@class User;
@class Photo;


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
@property (strong, nonatomic) NSString *galleryDescription;
@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) NSInteger selectedImageIndex;
@property (strong, nonatomic, readonly) NSString *galleryID;
@property (strong, nonatomic, readonly) NSString *folderPath;
@property (strong, nonatomic, readonly) User *owner;

- (instancetype)initWithDictionary:(NSDictionary *) dictionary andOwnerUser:(User *) user;

- (void)reloadContent;
- (void)getAdditionalContent;
- (void)cancelGetData;

- (Photo *)nextPhoto;
- (Photo *)previousPhoto;
- (Photo *)currentPhoto;
- (NSInteger)getPhotosCount;
- (NSInteger)nextPhotoIndex;
- (NSInteger)previousPhotoIndex;

- (NSString *)getLocalPathForPhoto:(Photo *)photo;
- (NSString *)getLocalPathForPrimaryPhoto;

- (void)getPhoto:(Photo *) photo sucsessNotification:(NSNotification *) notification;

- (void)setDataProvider:(id<PhotoProviderProtocol>)dataProvider;

- (void)addPhotos:(NSArray<UIImage *> *)photos;
- (void)addPrimaryPhoto:(UIImage *)cover;

- (void)deletePhotosByIndexes:(NSArray<NSNumber *> *)indexes;

@end

NS_ASSUME_NONNULL_END

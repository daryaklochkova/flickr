//
//  ListOfGalleries.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gallery.h"
#import "GalleriesListProvider.h"
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const PrimaryPhotoDownloadComplite;
extern NSString *const galleryIndex;

extern NSNotificationName const ListOfGalleriesSuccessfulRecieved;



@interface ListOfGalleries : NSObject // TODO impliment protocol <NSFastEnumeration>


@property (weak, nonatomic, readonly) User *owner;


- (instancetype)initWithUser:(User *) user;
- (void)setDataProvider:(id<GalleriesListProviderProtocol>)dataProvider;

- (void)updateContent;
- (void)getAdditionalContent;

- (void)deleteGallery:(NSSet<NSString *> *)galleryIDs;

- (Gallery *)addNewGallery:(NSDictionary *)galleryInfo;
- (void)changeGalleryInfo:(Gallery *)gallery;

- (Gallery *)getGalleryAtIndex:(NSInteger)index;
- (NSInteger)countOfGalleries;
- (NSArray<Gallery *> *)getGalleries;

- (NSInteger)getIndexForGallery:(NSString *)galleryID;
@end

NS_ASSUME_NONNULL_END

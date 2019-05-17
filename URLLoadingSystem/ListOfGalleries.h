//
//  ListOfGalleries.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gallery.h"
#import "GetListOfGalleriesResponseParser.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const PrimaryPhotoDownloadComplite;
extern NSString *const galleryIndex;

extern NSNotificationName const ListOfGalleriesRecieved;

@interface ListOfGalleries : NSObject // TODO impliment protocol <NSFastEnumeration>

@property (strong, nonatomic, readonly) NSString *userID;

- (instancetype)initWithUserID:(NSString *) userID;

- (void)getListOfGalleriesUsing:(id<DataProviderProtocol>) dataProvider;
- (void)addGallery:(Gallery *)gallery;
- (Gallery *)getGalleryAtIndex:(NSInteger)index;
- (NSInteger)countOfGalleries;

@end

NS_ASSUME_NONNULL_END

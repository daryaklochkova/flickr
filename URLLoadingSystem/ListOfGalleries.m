//
//  ListOfGalleries.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "ListOfGalleries.h"
#import "LocalPhotosProvider.h"
#import "PermissionManager.h"
#import "User.h"

NSNotificationName const PrimaryPhotoDownloadComplite = @"primaryPhotoDownloadComplite";
NSString *const galleryIndex = @"galleryIndex";

NSNotificationName const ListOfGalleriesSuccessfulRecieved = @"ListOfGalleriesRecieved";

@interface ListOfGalleries ()
@property (strong, nonatomic) NSMutableArray<Gallery *> *galleries;
@property (strong, nonatomic) id<GalleriesListProviderProtocol> dataProvider;
@property (assign, nonatomic) BOOL isUserOwner;
@end

@implementation ListOfGalleries

- (instancetype)initWithUser:(User *)user {
    self = [super init];
    
    if (self) {
        self.galleries = [[NSMutableArray alloc] init];
        _owner = user;
        
        self.isUserOwner = [[PermissionManager defaultManager] isLoginedUserHasPermissionForEditing:self.owner];
        
    }
    return self;
}

- (Gallery *)createGalleryWith:(NSDictionary *)dictionary {
    Gallery *gallery = [[Gallery alloc] initWithDictionary:dictionary andOwnerUser:self.owner];
    
    if (self.isUserOwner) {
        [gallery setDataProvider:[[LocalPhotosProvider alloc] init]];
    } else {
        [gallery setDataProvider:[[PhotoProvider alloc] init]];
    }
    
    [self.galleries addObject:gallery];
    return gallery;
}

- (void)createGalleriesUsing:(NSArray<NSDictionary *> *)dictionaries {
    for (NSDictionary *dictionary in dictionaries) {
        [self createGalleryWith:dictionary];
    }
}

- (Gallery *)addNewGallery:(NSDictionary *)galleryInfo {
    NSString *galleryID = [self.dataProvider getNextGalleryId];
    
    NSMutableDictionary *mutableInfo = [NSMutableDictionary dictionaryWithDictionary:galleryInfo];
    [mutableInfo setValue:galleryID forKey:[galleryIDArgumentName copy]];
    [mutableInfo setValue:self.owner.userID forKey:[userIDArgumentName copy]];
    
    Gallery *gallery = [self createGalleryWith:mutableInfo];
    
    [self.dataProvider saveGallery:gallery];

    return gallery;
}

- (void)changeGalleryInfo:(Gallery *)gallery {
    [self.dataProvider updateGalleryInfo:gallery];
}


#pragma mark - Update content

- (void)updateContent{
    @synchronized (self) {
         self.galleries = [NSMutableArray array];
    }
   
    [self.dataProvider getGalleriesForUser:self.owner.userID use:[self handleRequestResult]];
}

- (ReturnResult)handleRequestResult {
    
    __weak typeof(self) weakSelf = self;
    ReturnResult block = ^(NSArray * _Nullable result) {
        __strong typeof(self) strongSelf = weakSelf;
        
        @synchronized (strongSelf) {
            [strongSelf createGalleriesUsing:result];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ListOfGalleriesSuccessfulRecieved
                                                                object:nil];
        });
        
        [strongSelf getPrimaryPhotosFor:strongSelf.galleries];
    };
    
    return block;
}

- (void)getAdditionalContent{
     [self.dataProvider getAdditionalGalleriesForUser:self.owner.userID use:[self handleRequestResult]];
}

- (void)cancelGetListOfGalleriesTask{
    for (Gallery *gallery in self.galleries) {
        [gallery cancelGetData];
    }
}

- (void)getPrimaryPhotosFor:(NSArray<Gallery *> *)galleries {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        [galleries enumerateObjectsUsingBlock:^(Gallery * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [strongSelf getPrimaryPhotoFor:obj galleryIndex:idx];
        }];
        
    });
}

- (void)getPrimaryPhotoFor:(Gallery *) gallery galleryIndex:(NSInteger)index {
    NSDictionary *dictionary = @{
                                 locationKey:[gallery getLocalPathForPrimaryPhoto],
                                 galleryIndex:[NSNumber numberWithInteger:index]
                                 };
    
    NSNotification *fileDownloadCompliteNotification = [NSNotification notificationWithName:PrimaryPhotoDownloadComplite object:dictionary];
    
    [gallery getPhoto:gallery.primaryPhoto sucsessNotification:fileDownloadCompliteNotification];
}


#pragma mark - Work with galleries

- (void)addGallery:(Gallery *) gallery{
    @synchronized (self) {
        [self.galleries addObject:gallery];
    }
}

- (NSInteger)countOfGalleries{
    return self.galleries.count;
}

- (Gallery *)getGalleryAtIndex:(NSInteger) index{
    return self.galleries[index];
}

- (NSArray<Gallery *> *)getGalleries{
    return self.galleries;
}

- (void)deleteGallery:(NSSet<NSString *> *)galleryIDs {
    [self.dataProvider deleteGalleries:galleryIDs inFolder:self.owner.userFolder];    
    [self updateContent];
}

- (NSInteger)getIndexForGallery:(NSString *)galleryID {

    __block NSInteger index = -1;
    
    [self.galleries enumerateObjectsUsingBlock:^(Gallery * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.galleryID isEqualToString:galleryID]) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

@end

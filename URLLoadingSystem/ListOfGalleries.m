//
//  ListOfGalleries.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "ListOfGalleries.h"

NSNotificationName const PrimaryPhotoDownloadComplite = @"primaryPhotoDownloadComplite";
NSString *const galleryIndex = @"galleryIndex";

NSNotificationName const ListOfGalleriesSuccessfulRecieved = @"ListOfGalleriesRecieved";

@interface ListOfGalleries ()
@property (strong, nonatomic) NSMutableArray<Gallery *> *galleries;
@property (strong, nonatomic) id<GalleriesListProviderProtocol> dataProvider;
@end

@implementation ListOfGalleries

- (instancetype)initWithUserID:(NSString *) userID{
    self = [super init];
    
    if (self) {
        self.galleries = [[NSMutableArray alloc] init];
        _userID = userID;
    }
    return self;
}

- (void)setDataProviderToGalleries:(NSArray<Gallery *> *)galleries{
    for (Gallery *gallery in galleries) {
        [gallery setDataProvider:[[PhotoProvider alloc] init]];
    }
}


#pragma mark - Update content

- (void)updateContent{
    @synchronized (self) {
         self.galleries = [NSMutableArray array];
    }
   
    [self.dataProvider getGalleriesForUser:self.userID use:[self handleRequestResult]];
}

- (ReturnResult)handleRequestResult{
    __weak typeof(self) weakSelf = self;
    ReturnResult block = ^(NSArray * _Nullable result) {
        __weak typeof(self) strongSelf = weakSelf;
        
        @synchronized (strongSelf) {
            [strongSelf.galleries addObjectsFromArray:result];
        }
        
        [strongSelf setDataProviderToGalleries:result];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ListOfGalleriesSuccessfulRecieved object:nil];
        });
        
        [self getPrimaryPhotosFor:result];
    };
    
    return block;
}

- (void)getAdditionalContent{
     [self.dataProvider getAdditionalGalleriesForUser:self.userID use:[self handleRequestResult]];
}

- (void)cancelGetListOfGalleriesTask{
    for (Gallery *gallery in self.galleries) {
        [gallery cancelGetData];
    }
}

- (void)getPrimaryPhotosFor:(NSArray<Gallery *> *)galleries{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (NSInteger i = 0; i < galleries.count; i++) {
            Gallery *gallery = [galleries objectAtIndex:i];
            [self getPrimaryPhotoFor:gallery galleryIndex:i];
        }
    });
}

- (void)getPrimaryPhotoFor:(Gallery *) gallery galleryIndex:(NSInteger) index{
    NSDictionary *dictionary = @{locationKey:[gallery getLocalPathForPrimaryPhoto], galleryIndex:[NSNumber numberWithInteger:index]};
    
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
    return [self.galleries objectAtIndex:index];
}

- (NSArray<Gallery *> *)getGalleries{
    return self.galleries;
}

@end

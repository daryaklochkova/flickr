//
//  ListOfGalleries.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "ListOfGalleries.h"
#import "LocalPhotosProvider.h"

NSNotificationName const PrimaryPhotoDownloadComplite = @"primaryPhotoDownloadComplite";
NSString *const galleryIndex = @"galleryIndex";

NSNotificationName const ListOfGalleriesSuccessfulRecieved = @"ListOfGalleriesRecieved";

@interface ListOfGalleries ()
@property (strong, nonatomic) NSMutableArray<Gallery *> *galleries;
@property (strong, nonatomic) id<GalleriesListProviderProtocol> dataProvider;
@property (assign, nonatomic) BOOL isUserOwner;
@end

@implementation ListOfGalleries

- (instancetype)initWithUser:(User *) user{
    self = [super init];
    
    if (self) {
        self.galleries = [[NSMutableArray alloc] init];
        _user = user;
        
        NSString *logdedInUserID = [[NSUserDefaults standardUserDefaults] objectForKey:[LoginedUserID copy]];
        self.isUserOwner = [self.user.userID isEqualToString:logdedInUserID];
        
    }
    return self;
}

- (void)createGalleriesUsing:(NSArray<NSDictionary *> *)dictionaries {
    for (NSDictionary *dictionary in dictionaries) {
        Gallery *gallery = [[Gallery alloc] initWithDictionary:dictionary andUserFolder:self.user.userFolder];
        
        if (self.isUserOwner) {
            [gallery setDataProvider:[[LocalPhotosProvider alloc] init]];
        } else {
            [gallery setDataProvider:[[PhotoProvider alloc] init]];
        }
        
        [self.galleries addObject:gallery];
    }
}


#pragma mark - Update content

- (void)updateContent{
    @synchronized (self) {
         self.galleries = [NSMutableArray array];
    }
   
    [self.dataProvider getGalleriesForUser:self.user.userID use:[self handleRequestResult]];
}

- (ReturnResult)handleRequestResult {
    __weak typeof(self) weakSelf = self;
    
    ReturnResult block = ^(NSArray * _Nullable result) {
        __strong typeof(self) strongSelf = weakSelf;
        
        @synchronized (strongSelf) {
            [strongSelf createGalleriesUsing:result];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ListOfGalleriesSuccessfulRecieved object:nil];
        });
        
        [self getPrimaryPhotosFor:strongSelf.galleries];
    };
    
    return block;
}

- (void)getAdditionalContent{
     [self.dataProvider getAdditionalGalleriesForUser:self.user.userID use:[self handleRequestResult]];
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

- (void)getPrimaryPhotoFor:(Gallery *) gallery galleryIndex:(NSInteger)index {
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

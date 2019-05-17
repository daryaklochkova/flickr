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

NSNotificationName const ListOfGalleriesRecieved = @"ListOfGalleriesRecieved";

@interface ListOfGalleries ()
@property (strong, nonatomic) NSMutableArray<Gallery *> *galleries;
@property (strong, nonatomic) id<GalleryProviderProtocol> dataProvider;
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


- (void)startDownloadPrimaryPhotos{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (NSInteger i = 0; i < self.galleries.count; i++) {
            Gallery *gallery = [self.galleries objectAtIndex:i];
            [self downloadPrimaryPhotoFor:gallery galleryIndex:i];
        }
    });
}


- (void)downloadPrimaryPhotoFor:(Gallery *) gallery galleryIndex:(NSInteger) index{
    NSDictionary *dictionary = @{locationKey:[gallery getLocalPathForPrimaryPhoto], galleryIndex:[NSNumber numberWithInteger:index]};
    
    NSNotification *fileDownloadCompliteNotification = [NSNotification notificationWithName:PrimaryPhotoDownloadComplite object:dictionary];
    
    [gallery downloadPhoto:gallery.primaryPhoto sucsessNotification:fileDownloadCompliteNotification];
}


- (void)getListOfGalleriesUsing:(id<GalleryProviderProtocol>) dataProvider{
    self.dataProvider = dataProvider;
    
    [dataProvider getGalleriesForUser:self.userID use:^(NSArray * _Nullable result) {
        self.galleries = [NSMutableArray arrayWithArray:result];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ListOfGalleriesRecieved object:nil];
        });
        
        [self startDownloadPrimaryPhotos];
    }];
}

- (void)cancelGetListOfGalleriesTask{
    [self.dataProvider cancelTaskForUser:self.userID];
}

#pragma MARK - work with galleries

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

@end

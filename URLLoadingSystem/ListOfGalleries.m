//
//  ListOfGalleries.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "ListOfGalleries.h"

NSNotificationName const primaryPhotoDownloadComplite = @"primaryPhotoDownloadComplite";
NSString *const galleryIndex = @"galleryIndex";

@implementation ListOfGalleries

- (instancetype)init{
    self = [super init];
    
    if (self) {
        self.galleries = [[NSMutableArray alloc] init];
        self.request = [[GetListOfGalleriesRequest alloc] initWithUserID:@"66956608@N06"]; //26144115@N06
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startDownloadPrimaryPhotos:) name:ListOfGalleriesRecieved object:nil];
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)startDownloadPrimaryPhotos:(NSNotification *) notification{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (NSInteger i = 0; i < self.galleries.count; i++) {
            Gallery *gallery = [self.galleries objectAtIndex:i];
            [self downloadPrimaryPhotoFor:gallery galleryIndex:i];
        }
    });
}

- (void)downloadPrimaryPhotoFor:(Gallery *) gallery galleryIndex:(NSInteger) index{
    NSDictionary *dictionary = @{locationKey:[gallery getLocalPathForPrimaryPhoto], galleryIndex:[NSNumber numberWithInteger:index]};
    
    NSNotification *fileDownloadCompliteNotification = [NSNotification notificationWithName:primaryPhotoDownloadComplite object:dictionary];
    
    [gallery downloadPhoto:gallery.primaryPhoto sucsessNotification:fileDownloadCompliteNotification];
}


- (void)getListOfGalleries{
    NSURL *url = [self.request createRequest];
    NetworkManager *networkManager = [NetworkManager defaultNetworkManager];
    GetListOfGalleriesResponceParser *parser = [[GetListOfGalleriesResponceParser alloc] initWithListOfGalleries:self];
    
    SessionDataTaskCallBack completionHandler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:PhotosInformationReceived object:nil];
            
            NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:data];
            [nsXmlParser setDelegate:parser];
            [nsXmlParser parse];
        });
    };
    
    [networkManager fetchDataFromURL:url using:completionHandler];
}


@end

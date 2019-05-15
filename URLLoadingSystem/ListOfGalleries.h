//
//  ListOfGalleries.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gallery.h"
#import "GetListOfGalleriesRequest.h"
#import "GetListOfGalleriesResponceParser.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const primaryPhotoDownloadComplite;
extern NSString *const galleryIndex;

@interface ListOfGalleries : NSObject 

@property (strong, nonatomic) NSMutableArray<Gallery *> *galleries;

@property (strong, nonatomic) GetListOfGalleriesRequest *request;

- (void)getListOfGalleries;

@end

NS_ASSUME_NONNULL_END

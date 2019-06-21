//
//  LocalPhotosProvider.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 10/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PhotoProviderProtocol.h"

extern const NSNotificationName PhotosInGalleryWasChanged;
extern const NSString *changedGalleryKey;

NS_ASSUME_NONNULL_BEGIN

@interface LocalPhotosProvider : NSObject <PhotoProviderProtocol>

@end

NS_ASSUME_NONNULL_END

//
//  LocalGalleriesListProvider.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 06/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GalleriesListProviderProtocol.h"
#import "Gallery.h"

extern const NSNotificationName GalleriesInfoWasChanged;

NS_ASSUME_NONNULL_BEGIN

@interface LocalGalleriesListProvider : NSObject <GalleriesListProviderProtocol>

@end

NS_ASSUME_NONNULL_END

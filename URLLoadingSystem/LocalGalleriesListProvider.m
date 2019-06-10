//
//  LocalGalleriesListProvider.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 06/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "LocalGalleriesListProvider.h"

@implementation LocalGalleriesListProvider

- (void)getAdditionalGalleriesForUser:(NSString * _Nullable)userID use:(ReturnGalleriesResult _Nullable ) completionHandler {
    
}

- (void)getGalleriesForUser:(NSString *)userID use:(ReturnResult) completionHandler {
    NSArray *localGalleriesInfo = [[NSUserDefaults standardUserDefaults] objectForKey:[LocalGalleriesKey copy]];
    
    if (localGalleriesInfo) {
        completionHandler(localGalleriesInfo);
    }
}



@end

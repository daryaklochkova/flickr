//
//  LocalGalleriesListProvider.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 06/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "LocalGalleriesListProvider.h"
#import "NSUserDefaults.h"

@interface LocalGalleriesListProvider()
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@end


@implementation LocalGalleriesListProvider

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)getAdditionalGalleriesForUser:(NSString * _Nullable)userID use:(ReturnGalleriesResult _Nullable ) completionHandler {
    
}

- (void)getGalleriesForUser:(NSString *)userID use:(ReturnResult) completionHandler {
    NSArray *localGalleriesInfo = [self.userDefaults getLocalGalleriesInfo];
    
    if (localGalleriesInfo) {
        completionHandler(localGalleriesInfo);
    }
}

- (void)saveGallery:(Gallery *)gallery {
    NSDictionary *galleryInfo = @{
                                  galleryIDArgumentName:gallery.galleryID,
                                  titleArgumentName:gallery.title,
                                  descriptionArgumentName:gallery.description,
                                  userIDArgumentName:gallery.owner.userID,
                                  @"photos":[NSMutableArray array]
                                  };
    
    [self.userDefaults saveGalleryInfoInUserDefaults:galleryInfo.mutableCopy];
}

- (NSString *)getNextGalleryId {
    @synchronized (self) {
        NSArray *localGalleriesInfo = [[NSUserDefaults standardUserDefaults] objectForKey:[LocalGalleriesKey copy]];
        
        if (localGalleriesInfo) {
            return [NSString stringWithFormat:@"%lu",(unsigned long)localGalleriesInfo.count];
        } else {
            return @"0";
        }
    }
}

- (void)deleteGalleries:(NSSet<NSString *> *)galleryIDs inFolder:(NSString *)path {
    //1) clear userDefaults
    //2) delete gallery folder and all photos
    
    for (NSString *galleryID in galleryIDs) {
        [self.userDefaults deleteGalleryInfoByID:galleryID];
        
        NSString *pathPart = [NSString stringWithFormat:@"Assets/%@", galleryID];
        NSString *folderPath = [path stringByAppendingPathComponent:pathPart];
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:folderPath error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
}

@end

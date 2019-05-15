//
//  Photo.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 08/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Photo : NSObject

@property (strong, nonatomic, readonly) NSString *photoID;
@property (strong, nonatomic, readonly) NSString *owner;
@property (strong, nonatomic, readonly) NSString *secret;
@property (strong, nonatomic, readonly) NSString *server;
@property (strong, nonatomic, readonly) NSString *farm;
@property (strong, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSString *isPublic;
@property (strong, nonatomic, readonly) NSString *isFriend;
@property (strong, nonatomic, readonly) NSString *isFamily;
@property (strong, nonatomic, readonly) NSString *isPrimary;
@property (strong, nonatomic, readonly) NSString *hasComment;

@property (strong, nonatomic, readonly) NSURL *remoteURL;
@property (strong, nonatomic, readonly) NSString *name;

-(instancetype)initWithDictionary:(NSDictionary *) dictionary;
- (instancetype)initPrimaryPhotoWithDictionary:(NSDictionary *) dictionary;
@end

NS_ASSUME_NONNULL_END

//
//  GetListOfGalleriesResponceParser.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 13/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListOfGalleries.h"

NS_ASSUME_NONNULL_BEGIN
@class ListOfGalleries;

extern NSNotificationName const ListOfGalleriesRecieved;

@interface GetListOfGalleriesResponceParser : NSObject <NSXMLParserDelegate>

@property (weak, nonatomic) ListOfGalleries *listOfGalleries;

@property (strong, nonatomic) NSString *currentElement;
@property (strong, nonatomic) Gallery *currentGallery;

- (instancetype)initWithListOfGalleries:(ListOfGalleries *)listOfGalleries;

@end

NS_ASSUME_NONNULL_END

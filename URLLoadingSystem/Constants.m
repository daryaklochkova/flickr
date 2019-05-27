//
//  Constants.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 24/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "Constants.h"

const NSString *baseURL = @"https://www.flickr.com/services/rest/";
const NSString *apiKeyValue = @"85974c3f3e4f62fd98efb4422277c008";
const NSString *apiKey = @"api_key";

const NSString *getGalleriesListMethod = @"flickr.galleries.getList";
const NSString *getGalleriesGetPhotoMethod = @"flickr.galleries.getPhotos";
const NSString *methodArgumentName = @"method";


const NSString *formatArgumentName = @"format";
const NSString *userIDArgumentName = @"user_id";
const NSString *continuationArgumentName = @"continuation";
const NSString *shortLimitArgumentName = @"short_limit";
const NSString *perPageArgumentName = @"per_page";
const NSString *galleryIDArgumentName = @"gallery_id";

const NSString *continuationStartValue = @"0";
const NSString *continuationEndValue = @"-1";


const NSString *errorKey = @"erorKey";

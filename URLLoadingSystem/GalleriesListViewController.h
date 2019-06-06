//
//  ViewController.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 06/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListOfGalleries.h"
#import "GalleryCell.h"
#import "GalleryPhotosViewController.h"
#import "GalleriesListProvider.h"
#import "User.h"

@interface GalleriesListViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) ListOfGalleries *listOfGalleries;
@property (strong, nonatomic) User *user;

@end


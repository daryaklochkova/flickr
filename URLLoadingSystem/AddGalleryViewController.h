//
//  AddGalleryViewController.h
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 05/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "ListOfGalleries.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddGalleryViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) User *galleryOwner;
@property (strong, nonatomic) ListOfGalleries *galleries;
@end

NS_ASSUME_NONNULL_END

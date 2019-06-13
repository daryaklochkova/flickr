//
//  AddGalleryViewController.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 05/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "AddGalleryViewController.h"
#import "Gallery.h"
#import "Constants.h"
#import "AddPhotosToGalleryViewController.h"

@interface AddGalleryViewController ()
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *galleryTitleTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@property (strong, nonatomic) NSMutableArray *selectedImages;

@property (strong, nonatomic) Gallery *galleryNew;

@end

@implementation AddGalleryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
    [self subscribeToNotifications];
    
    self.selectedImages = [NSMutableArray array];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizer:)];
    [self.view addGestureRecognizer:recognizer];
}

- (void)tapRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self.view endEditing:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureLayout {
    CALayer *textViewLayer = self.descriptionTextView.layer;
    
    textViewLayer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
    textViewLayer.borderWidth = 0.5;
    textViewLayer.cornerRadius = 8;
    self.descriptionTextView.clipsToBounds = YES;
}

- (void)subscribeToNotifications {
    
    NSNotificationCenter *notificetionCenter = [NSNotificationCenter defaultCenter];
    
    [notificetionCenter addObserver:self
                           selector:@selector(keyboardWillShow:)
                               name:UIKeyboardWillShowNotification
                             object:nil];
    
    [notificetionCenter addObserver:self
                           selector:@selector(keyboardWillHide:)
                               name:UIKeyboardWillHideNotification
                             object:nil];
}


#pragma mark - Keyboard notifications

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect fieldFrame;
    if ([self.descriptionTextView isFirstResponder]) {
        fieldFrame = [self.descriptionTextView convertRect:self.descriptionTextView.frame toView:self.view];
    }
    else if ([self.galleryTitleTextField isFirstResponder]) {
        fieldFrame = [self.galleryTitleTextField convertRect:self.galleryTitleTextField.frame toView:self.view];
    }
    fieldFrame.size.height += 5;
    
    if (CGRectIntersectsRect(fieldFrame, keyboardFrame)) {
        CGSize keyboardSize = keyboardFrame.size;
        CGFloat distanceToBottom = (self.view.frame.size.height - fieldFrame.size.height - fieldFrame.origin.y - 5);
        CGFloat diff = keyboardSize.height - distanceToBottom;
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(-diff, 0.0, 0.0, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
    }
}

- (void)keyboardWillHide:(NSNotification*)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.galleryTitleTextField resignFirstResponder];
    [self.descriptionTextView becomeFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing");
}

#pragma mark - UI actions

- (BOOL)allRequiredFieldsAreFilled:(NSString **)message {
    NSMutableString *mutableMessage = @"".mutableCopy;
    
    if ([self.galleryTitleTextField.text isEqualToString:@""]) {
        [mutableMessage appendString:@"The title field is empty"];
    }
    
    if (![mutableMessage isEqualToString:@""]) {
        *message = mutableMessage;
        return NO;
    }
    return YES;
}

- (void)saveImage:(UIImage *)image named:(NSString *)fileName byPath:(NSString *)path {
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
}

- (void)saveGalleryInfoInUserdDefaults:(NSMutableDictionary *)galleryInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *localGalleriesInfo = [userDefaults objectForKey:[LocalGalleriesKey copy]];
    if (localGalleriesInfo) {
        NSMutableArray *mutableGalleriesInfo = [NSMutableArray arrayWithArray:localGalleriesInfo];
        [mutableGalleriesInfo addObject:galleryInfo];
        [userDefaults setObject:mutableGalleriesInfo forKey:[LocalGalleriesKey copy]];
    }
    else {
        [userDefaults setObject:@[galleryInfo] forKey:[LocalGalleriesKey copy]];
    }
}

- (NSString *)getNextGalleryId {
    NSArray *localGalleriesInfo = [[NSUserDefaults standardUserDefaults] objectForKey:[LocalGalleriesKey copy]];
    if (localGalleriesInfo) {
        return [NSString stringWithFormat:@"%lu",(unsigned long)localGalleriesInfo.count];
    } else {
        return @"0";
    }
}

- (NSMutableArray *)getPgotosArrayForGallery:(NSString *)galleryID byPath:(NSString *)path {
    NSMutableArray *photos = [NSMutableArray array];
    for (int i = 0; i < self.selectedImages.count; i++) {
        UIImage *image = [self.selectedImages objectAtIndex:i];
        NSString *fileName = [NSString stringWithFormat:@"%@_%ld", galleryID, (long)i];
        [self saveImage:image named:fileName byPath:path];
        [photos addObject:fileName];
    }
    return photos;
}

- (void)saveGalleryInUserDefaults {
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:[LoginedUserID copy]];
    NSString *galleryID = [self getNextGalleryId];
    
    NSDictionary *galleryInfo = @{
                                  galleryIDArgumentName:galleryID,
                                  titleArgumentName:self.galleryTitleTextField.text,
                                  descriptionArgumentName:self.descriptionTextView.text,
                                  userIDArgumentName:userID
                                  };
    
    self.galleryNew = [[Gallery alloc] initWithDictionary:galleryInfo andUserFolder:self.galleryOwner.userFolder];
    NSString *path = self.galleryNew.folderPath;
    
    NSMutableArray * photos = [self getPgotosArrayForGallery:galleryID byPath:path];
    
    NSMutableDictionary *galleryInfoWithPhotos = [[NSMutableDictionary alloc] initWithDictionary:galleryInfo];
    [galleryInfoWithPhotos setValue:photos forKey:@"photos"];
    
    if (![self.coverImageView.image isEqual:[UIImage imageNamed:@"Add photo"]]) {
        NSString *primaryPhotoName = [NSString stringWithFormat:@"%@_primaryPhoto", galleryID];
        [self saveImage:self.coverImageView.image named:primaryPhotoName byPath:path];
        [galleryInfoWithPhotos setValue:primaryPhotoName forKey:[primaryPhotoIdArgumentName copy]];
    }
    
    [self saveGalleryInfoInUserdDefaults:galleryInfoWithPhotos];
}

- (IBAction)saveNewGallery:(id)sender {
    NSString *message;
    if (![self allRequiredFieldsAreFilled:&message]) {
        [self showErrorAlertWithTitle:@"Error" andMessage:message];
        return;
    }
    [self saveGalleryInUserDefaults];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tapToImage:(UITapGestureRecognizer *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        
        [self showErrorAlertWithTitle:@"Error" andMessage:@"Device has no camera"];
        
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)showErrorAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleCancel
                             handler:nil];
    
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.coverImageView.image = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    UIViewController *destinationController = segue.destinationViewController;
    
    if ([destinationController isKindOfClass:[AddPhotosToGalleryViewController class]]) {
        AddPhotosToGalleryViewController *addPhotosVC = (AddPhotosToGalleryViewController *)destinationController;
        addPhotosVC.selectedImages = self.selectedImages;
    }
}


@end

//
//  AddGalleryViewController.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 05/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "AddGalleryViewController.h"
#import "Constants.h"
#import "AddPhotosToGalleryViewController.h"
#import "LocalGalleriesListProvider.h"
#import "GalleryPhotosViewController.h"
#import "AlertManager.h"
#import "WorkModes.h"
#import "User.h"
#import "ListOfGalleries.h"
#import "Gallery.h"

@interface AddGalleryViewController ()
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *galleryTitleTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (strong, nonatomic) UIImage *coverImage;

@property (strong, nonatomic) NSMutableArray<UIImage *> *selectedImages;

@end

@implementation AddGalleryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
    [self subscribeToNotifications];
    
    if (self.editGallery) {
        self.galleryTitleTextField.text  = self.editGallery.title;
        self.descriptionTextView.text = self.editGallery.galleryDescription;
        self.selectedImages = [NSMutableArray array];
        
        NSString *filePath = [self.editGallery getLocalPathForPrimaryPhoto];
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        self.coverImageView.image = image;
        
    }
    else {
        self.selectedImages = [NSMutableArray array];
    }
    
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
    static NSInteger spaceToKeyboard = 5;
    
    CGRect fieldFrame;
    if ([self.descriptionTextView isFirstResponder]) {
        fieldFrame = [self.descriptionTextView.superview convertRect:self.descriptionTextView.frame toView:self.view];
    }
    else if ([self.galleryTitleTextField isFirstResponder]) {
        fieldFrame = [self.galleryTitleTextField.superview convertRect:self.galleryTitleTextField.frame toView:self.view];
    }
    else {
        return;
    }
 
    fieldFrame.size.height += spaceToKeyboard;
    
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (CGRectIntersectsRect(fieldFrame, keyboardFrame)) {
        CGSize keyboardSize = keyboardFrame.size;
        CGFloat distanceToBottom = (self.view.frame.size.height - fieldFrame.size.height - fieldFrame.origin.y + spaceToKeyboard);
        CGFloat diff = keyboardSize.height - distanceToBottom + spaceToKeyboard;
        CGPoint point = CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y + diff);
        [self.scrollView setContentOffset:point animated:YES];
    }
}


- (void)keyboardWillHide:(NSNotification*)notification {
//    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//    self.scrollView.contentInset = contentInsets;
//    self.scrollView.scrollIndicatorInsets = contentInsets;
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
        [mutableMessage appendString:NSLocalizedString(@"The title field is empty", nil)];
    }
    
    if (![mutableMessage isEqualToString:@""]) {
        *message = mutableMessage;
        return NO;
    }
    return YES;
}


- (void)addNewGallery {
    NSDictionary *info = @{
                           descriptionArgumentName:self.descriptionTextView.text,
                           titleArgumentName:self.galleryTitleTextField.text,
                           };
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.editGallery = [strongSelf.galleries addNewGallery:info];
        
        if (strongSelf.selectedImages.count > 0) {
            [strongSelf.editGallery addPhotos:strongSelf.selectedImages];
        }
        
        if (strongSelf.coverImage) {
            [strongSelf.editGallery addPrimaryPhoto:strongSelf.coverImage];
        }
    });
}

- (void)changeGalleryInfo {
    self.editGallery.title = self.galleryTitleTextField.text;
    self.editGallery.galleryDescription = self.descriptionTextView.text;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.galleries changeGalleryInfo:strongSelf.editGallery];
        
        if (strongSelf.coverImage) {
            [strongSelf.editGallery addPrimaryPhoto:strongSelf.coverImage];
        }
    });
}

- (IBAction)saveGallery:(id)sender {
    NSString *message;
    if (![self allRequiredFieldsAreFilled:&message]) {
        [self showErrorAlertWithTitle:NSLocalizedString(@"Error", nil)  andMessage:message];
        return;
    }
    
    if (!self.editGallery && self.galleries) {
        [self addNewGallery];
    }
    else {
        [self changeGalleryInfo];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tapToImage:(UITapGestureRecognizer *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        
        [self showErrorAlertWithTitle:NSLocalizedString(@"Error", nil)  andMessage:NSLocalizedString(@"Device has no camera", nil)];
        
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)showErrorAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertController *alert = [[AlertManager defaultManager] showErrorAlertWithTitle:title andMessage:message];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.coverImageView.image = info[UIImagePickerControllerEditedImage];
    self.coverImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue  *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    UIViewController *destinationController = segue.destinationViewController;
    
    if ([destinationController isKindOfClass:[AddPhotosToGalleryViewController class]]) {
        AddPhotosToGalleryViewController *addPhotosVC = (AddPhotosToGalleryViewController *)destinationController;
        addPhotosVC.selectedImages = self.selectedImages;
    }
}

- (IBAction)editPhotos:(id)sender {
    if (self.editGallery.galleryID) {
        UIStoryboard *nextStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GalleryPhotosViewController *nextViewController = [nextStoryBoard instantiateViewControllerWithIdentifier:@"galleryPhotosVC"];
        nextViewController.gallery = self.editGallery;
        nextViewController.workMode = editMode;
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
    else {
        UIStoryboard *nextStoryBoard = [UIStoryboard storyboardWithName:@"AddGallery" bundle:nil];
        AddPhotosToGalleryViewController *nextViewController = [nextStoryBoard instantiateViewControllerWithIdentifier:@"AddPhotosVC"];
        nextViewController.selectedImages = self.selectedImages;
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

@end

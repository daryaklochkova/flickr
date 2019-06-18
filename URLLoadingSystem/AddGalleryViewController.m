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
#import "GalleriesListViewProtocol.h"
#import "AlertManager.h"
#import "WorkModes.h"

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
        [mutableMessage appendString:NSLocalizedString(@"The title field is empty", nil)];
    }
    
    if (![mutableMessage isEqualToString:@""]) {
        *message = mutableMessage;
        return NO;
    }
    return YES;
}


- (IBAction)saveGallery:(id)sender {
    NSString *message;
    if (![self allRequiredFieldsAreFilled:&message]) {
        [self showErrorAlertWithTitle:NSLocalizedString(@"Error", nil)  andMessage:message];
        return;
    }
    
    if (!self.editGallery && self.galleries) {
        NSDictionary *info = @{
                               descriptionArgumentName:self.descriptionTextView.text,
                               titleArgumentName:self.galleryTitleTextField.text,
                               };
        
        self.editGallery = [self.galleries addNewGallery:info];
        
        if (self.selectedImages.count > 0) {
            [self.editGallery addPhotos:self.selectedImages];
        }
        
        if (self.coverImage) {
            [self.editGallery addPrimaryPhoto:self.coverImage];
        }
    }
    else {
        self.editGallery.title = self.galleryTitleTextField.text;
        self.editGallery.galleryDescription = self.descriptionTextView.text;
        [self.galleries changeGalleryInfo:self.editGallery];
        
        if (self.coverImage) {
            [self.editGallery addPrimaryPhoto:self.coverImage];
        }
    }
    

    
    NSArray *viewControllers = [self.navigationController viewControllers];
    UIViewController *parentViewController = [viewControllers objectAtIndex:viewControllers.count - 2];
    
    if ([parentViewController conformsToProtocol:@protocol(GalleriesListViewProtocol)]) {
        ((id <GalleriesListViewProtocol>)parentViewController).needReloadContent = YES;
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

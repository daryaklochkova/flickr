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
#import "LocalGalleriesListProvider.h"

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


- (IBAction)createNewGallery:(id)sender {
    NSString *message;
    if (![self allRequiredFieldsAreFilled:&message]) {
        [self showErrorAlertWithTitle:@"Error" andMessage:message];
        return;
    }
    if (self.galleries) {
    NSDictionary *galleryInfo = @{
                                  titleArgumentName:self.galleryTitleTextField.text,
                                  descriptionArgumentName:self.descriptionTextView.text,
                                  @"photos":[NSMutableArray array]
                                  };

        Gallery* gallery = [self.galleries addNewGallery:galleryInfo];
        [gallery addPhotos:self.selectedImages];
        [gallery addPrimaryPhoto:self.coverImageView.image];
    }
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    UIViewController *destinationController = segue.destinationViewController;
    
    if ([destinationController isKindOfClass:[AddPhotosToGalleryViewController class]]) {
        AddPhotosToGalleryViewController *addPhotosVC = (AddPhotosToGalleryViewController *)destinationController;
        addPhotosVC.selectedImages = self.selectedImages;
    }
}


@end

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

@interface AddGalleryViewController ()
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *galleryTitleTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) Gallery *galleryNew;

@end

@implementation AddGalleryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
    [self subscribeToNotifications];
    
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
        fieldFrame = self.descriptionTextView.frame;
    }
    else if ([self.galleryTitleTextField isFirstResponder]) {
        fieldFrame = self.galleryTitleTextField.frame;
    }
    fieldFrame.size.height += 10;
    
    if (CGRectIntersectsRect(fieldFrame, keyboardFrame)) {
        CGSize keyboardSize = keyboardFrame.size;
        CGFloat distanceToBottom = (self.view.frame.size.height - fieldFrame.size.height - fieldFrame.origin.y - 10);
        CGFloat diff = keyboardSize.height - distanceToBottom;
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(-diff, 0.0, 0.0, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        
//        CGSize newSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + diff);
//        self.scrollView.contentSize = newSize;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - UI actions

- (IBAction)cancelAddGallery:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveNewGallery:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [userDefaults objectForKey:[LogdedInUserID copy]];
    
    NSDictionary *galleryInfo = @{
                                    @"gallery_id":@"1",
                                    @"title":self.galleryTitleTextField.text,
                                    @"description":self.descriptionTextView.text,
                                    @"user_id":userID
                                    };
    
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


@end

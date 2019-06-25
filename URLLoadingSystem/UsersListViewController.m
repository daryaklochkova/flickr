//
//  UsersListViewController.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 05/06/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "UsersListViewController.h"
#import "User.h"
#import "GalleriesListViewController.h"

@interface UsersListViewController ()
@property (strong, nonatomic) NSMutableArray<User *> *usersList;
@property (strong, nonatomic) NSIndexPath *selectedRow;
@end

@implementation UsersListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:LocalGalleriesKey];
    
    User *flickr = [[User alloc] initWithUserID:@"66956608@N06" andName:@"Flickr" andFolderDirectory:NSCachesDirectory];
    User *testUser = [[User alloc] initWithUserID:@"0" andName:@"Test user" andFolderDirectory:NSDocumentDirectory];
    
    self.usersList = [NSMutableArray arrayWithObjects: flickr, testUser, nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destinationVC = [segue destinationViewController];
    
    if ([destinationVC isKindOfClass:[GalleriesListViewController class]]){
        GalleriesListViewController *galleriesListVC = (GalleriesListViewController *)destinationVC;
        NSInteger index = [self.selectedRow indexAtPosition:1];
        galleriesListVC.owner = self.usersList[index];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedRow = indexPath;
}

#pragma mark - UITableViewDataSourse
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath { 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    
    NSInteger index = [indexPath indexAtPosition:1];
    cell.textLabel.text = self.usersList[index].userName;

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return 2;
}


@end

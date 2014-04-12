//
//  InventoryMasterViewController.m
//  Inv Helper
//
//  Created by 谢 祖铭 on 13-7-28.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import "Constants.h"
#import "InventoryMasterViewController.h"
#import "InventoryEditViewController.h"
#import "InventoryDetailViewController.h"
#import "InventoryItem.h"
#import "InventoryItemDao.h"
#import "InventoryItemHelper.h"
#import "HttpInvoker.h"
#import "PhotoDao.h"

static const int SEARCH_SCOPE_ALL = 0;

@interface InventoryMasterViewController()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *uploadButton;
@property NSDictionary *userInfo;

@end

@implementation InventoryMasterViewController

@synthesize uploadButton;
@synthesize userInfo;


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [self.navigationController setToolbarHidden:NO];
    /*UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [[InventoryItemDao instance] countOfFilteredList];
    } else {
        return [[InventoryItemDao instance] countOfList];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InventoryItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    InventoryItem *item;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        item = [[InventoryItemDao instance] objectInFilteredListAtIndex:indexPath.row];
    } else {
        item = [[InventoryItemDao instance] objectInListAtIndex:indexPath.row];
    }
    
    NSString *title = [NSString stringWithFormat:@"%@: %@", item.itemId, item.title];
    [[cell textLabel] setText: title];
    [[cell detailTextLabel] setText:item.desc];
    [[cell imageView] setImage:[[PhotoDao instance] getScaleImageByPhotoName:item.photoname1
                                                                 toScaleSize:PHOTO_THUMBNAIL_SIZE_LIST]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        InventoryItem * item = [[InventoryItemDao instance] objectInListAtIndex:indexPath.row];
        // delete photos
        PhotoDao *photoDao = [PhotoDao instance];
        [photoDao beginTransaction];
        if ([item photoname1]) [photoDao deletePhotoWithPhotoName:[item photoname1]];
        if ([item photoname2]) [photoDao deletePhotoWithPhotoName:[item photoname2]];
        if ([item photoname3]) [photoDao deletePhotoWithPhotoName:[item photoname3]];
        [photoDao commit];
        // delete item record from DB
        [[InventoryItemDao instance] removeInventoryItem:item];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showInventoryItemDetail" sender:tableView];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    searchString = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *scope = [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    [[InventoryItemDao instance] filterContentForSearchText:searchString scope:scope];
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    NSString *searchString = [self.searchDisplayController.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *scope = [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption];
    [[InventoryItemDao instance] filterContentForSearchText:searchString scope:scope];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self initiateSearch];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self initiateSearch];
}

-(void)initiateSearch {
    // The UISearchDisplayController is implemented in a way that the results table won't be shown until some text is entered. There's also a bug report about this: ID# 8839635. The main thing is to add an extra character for the scope(s) that you want to show search results for automatically, but ensure that you remove it for the scope(s) that you do not want to do this.
    NSString *searchText = self.searchDisplayController.searchBar.text;
    NSString *strippedText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (strippedText.length != 0) {
        return;
    }
    NSInteger scope = self.searchDisplayController.searchBar.selectedScopeButtonIndex;
    if (scope == SEARCH_SCOPE_ALL) {
        if ((strippedText.length == 0) && (searchText.length != 0)) {
            self.searchDisplayController.searchBar.text = @"";
        }
    } else if (searchText.length == 0){
        self.searchDisplayController.searchBar.text = @" ";
    }
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showInventoryItemDetail"]) {
        InventoryDetailViewController *detailViewController = [segue destinationViewController];
        InventoryItem *selectedItem;
        if(sender == self.searchDisplayController.searchResultsTableView) {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            selectedItem = [[InventoryItemDao instance] objectInFilteredListAtIndex:indexPath.row];
        }
        else {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            selectedItem = [[InventoryItemDao instance] objectInListAtIndex:indexPath.row];
        }
        detailViewController.invertoryItem = selectedItem;
    }
}

- (IBAction)done:(UIStoryboardSegue *)segue
{
    if ([[segue identifier] isEqualToString:@"ReturnInput"]) {
        
        InventoryEditViewController *addController = [segue sourceViewController];
        
        if (addController.inventoryItem) {
            [[self tableView] reloadData];
        }
         
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (IBAction)cancel:(UIStoryboardSegue *)segue
{
    if ([[segue identifier] isEqualToString:@"CancelInput"]) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (IBAction)export:(id)sender {
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HHmmss"];
    }
    
    NSString *message;
    NSString *fileName = [NSString stringWithFormat:@"%@.txt", [dateFormatter stringFromDate:[NSDate date]]];
    if ([[InventoryItemDao instance] exportAllDataToFile:fileName]) {
        message = [NSString stringWithFormat:@"Export the file successfully.\n%@", fileName];
    } else {
        message = @"Failed to export the file";
    }
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Message"
                                                          message:message
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
    [myAlertView show];

}

- (IBAction)upload:(id)sender {
    NSString *userName;
    NSString *password;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *settings = [ud objectForKey:@"settings"];
    if (settings) {
        userName = [settings objectForKey:@"userName"];
        password = [settings objectForKey:@"password"];
    }
    if (!settings || [userName length] == 0 || [password length] == 0) {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Input settings first"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];
        return;
    }
    
    HttpInvokerResult *result = [HttpInvoker call:@"login" WithParams:[[NSDictionary alloc] initWithObjectsAndKeys:userName, @"userName", password, @"password",nil]];
    if (![result isOK]) {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:[result message]
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];
        return;
    }
    
    [uploadButton setTitle:@"Upload..."];
    [uploadButton setEnabled:FALSE];
    userInfo = [result data];
    [NSThread detachNewThreadSelector:@selector(uploadInBackground)
                             toTarget:self
                           withObject:nil];
}


-(void)uploadInBackground {
    
    HttpInvokerResult *result = nil;
    
    unsigned long itemCount = [[InventoryItemDao instance] countOfList];
    for (NSUInteger i = 0; i < itemCount; i++) {
        HttpInvokerResult *r = [self uploadItemAtIndex:i];
        if (!r.isOK) {
            result = r;
            break;
        }
    }
    
    if (!result) {
        result = [HttpInvokerResult createSuccessfulResultWithMessage:[NSString stringWithFormat:@"Upload all items successfully.\nItems: %ld", itemCount]];
    }
    
    [self performSelectorOnMainThread:@selector(afterUpload:) withObject:result waitUntilDone:TRUE];
}

-(HttpInvokerResult *)uploadItemAtIndex:(unsigned long)index{
    HttpInvokerResult *result;
    InventoryItem *item = [[InventoryItemDao instance] objectInListAtIndex:index];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[InventoryItemHelper convertItemToDict:item KeepType:true]];
    [params setValuesForKeysWithDictionary:userInfo];
    result = [HttpInvoker call:@"add_item" WithParams:params];
    if (!result.isOK) {
        return [HttpInvokerResult createFialedResultWithMessage:
                [NSString stringWithFormat:@"Failed to upload item[%ld]: %@", index+1, [result message]]];
    }
    
    NSMutableArray *photoPaths = [[NSMutableArray alloc] init];
    if ([item photoname1])
        [photoPaths addObject:[[PhotoDao instance] getPhotoPath:[item photoname1]]];
    if ([item photoname2])
        [photoPaths addObject:[[PhotoDao instance] getPhotoPath:[item photoname2]]];
    if ([item photoname3])
        [photoPaths addObject:[[PhotoDao instance] getPhotoPath:[item photoname3]]];
    
    params = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
    for (NSString *photoPath in photoPaths) {
        result = [HttpInvoker uploadFile:photoPath WithParams:params];
        if (!result.isOK) {
            return [HttpInvokerResult createFialedResultWithMessage:
                    [NSString stringWithFormat:@"Failed to upload the photo file of item[%ld]: %@", index, [result message]]];
        }
    }
    
    return [HttpInvokerResult createSuccessfulResultWithData:nil];
}

-(void)afterUpload:(id) result {
    [uploadButton setTitle:@"Upload"];
    [uploadButton setEnabled:TRUE];

    HttpInvokerResult *r = result;

    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:r.isOK ? @"Message" : @"Error"
                                                          message:r.message
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
    [myAlertView show];
}

@end

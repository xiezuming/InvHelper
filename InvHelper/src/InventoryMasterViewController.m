//
//  InventoryMasterViewController.m
//  Inv Helper
//
//  Created by 谢 祖铭 on 13-7-28.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import "InventoryMasterViewController.h"

#import "InventoryEditViewController.h"
#import "InventoryDetailViewController.h"
#import "InventoryItem.h"
#import "InventoryItemDao.h"
#import "PhotoDao.h"

static const CGSize PHOTO_THUMBNAIL_SIZE = {44, 44};

@implementation InventoryMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

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
    return [[InventoryItemDao getInstance] countOfList];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InventoryItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    InventoryItem *item = [[InventoryItemDao getInstance] objectInListAtIndex:indexPath.row];
    
    [[cell textLabel] setText:item.title];
    [[cell detailTextLabel] setText:item.desc];
    [[cell imageView] setImage:[[PhotoDao instance] getScaleImageByPhotoName:item.photoname1
                                                                 toScaleSize:PHOTO_THUMBNAIL_SIZE]];
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
        InventoryItemDao *dao = [InventoryItemDao getInstance];
        [dao removeInventoryItem:[dao objectInListAtIndex:indexPath.row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showInventoryItemDetail"]) {
        InventoryDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.invertoryItem = [[InventoryItemDao getInstance] objectInListAtIndex:[self.tableView indexPathForSelectedRow].row];
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
@end

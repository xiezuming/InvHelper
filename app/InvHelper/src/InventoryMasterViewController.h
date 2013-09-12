//
//  InventoryMasterViewController.h
//  Inv Helper
//
//  Created by 谢 祖铭 on 13-7-28.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InventoryItemDao;

@interface InventoryMasterViewController : UITableViewController

- (IBAction)done:(UIStoryboardSegue *)segue;
- (IBAction)cancel:(UIStoryboardSegue *)segue;
- (IBAction)export:(id)sender;
- (IBAction)upload:(id)sender;

@end

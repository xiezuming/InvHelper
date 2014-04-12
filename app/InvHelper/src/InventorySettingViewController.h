//
//  InventorySettingViewController.h
//  InvHelper
//
//  Created by 谢 祖铭 on 13-9-7.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InventorySettingViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *serverTextField;
@property (weak, nonatomic) IBOutlet UITextField *timeoutTextField;
@property (weak, nonatomic) IBOutlet UITextField *photoMaxPixelTextField;
@property (weak, nonatomic) IBOutlet UITextField *photoQualityTextField;

@end

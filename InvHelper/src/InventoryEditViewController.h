//
//  AddSightingViewController.h
//  Inv Helper
//
//  Created by 谢 祖铭 on 13-8-3.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ZBarSDK.h"

@class InventoryItem;

@interface InventoryEditViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, ZBarReaderDelegate>

@property Boolean isUpdate;
@property (strong, nonatomic) InventoryItem *inventoryItem;
@property (nonatomic, retain) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *barCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;
@property (weak, nonatomic) IBOutlet UITextField *conditionTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextField *sizeTextField;
@property (weak, nonatomic) IBOutlet UITextField *weightTextField;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *updateLocationButton;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *photo0ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *photo1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *photo2ImageView;
@property (weak, nonatomic) IBOutlet UIButton *photo0DeleteButton;
@property (weak, nonatomic) IBOutlet UIButton *photo1DeleteButton;
@property (weak, nonatomic) IBOutlet UIButton *photo2DeleteButton;

- (IBAction)photoImageViewClick:(id)sender;
- (IBAction)touchPhotoDelete:(id)sender;
- (IBAction)scanBarCode:(id)sender;
- (IBAction)updateLocation:(id)sender;

@end

//
//  AddSightingViewController.m
//  Inv Helper
//
//  Created by 谢 祖铭 on 13-8-3.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import "InventoryEditViewController.h"
#import "InventoryItem.h"
#import "InventoryItemDao.h"
#import "PhotoDao.h"
#import "HttpInvoker.h"
#import <QuartzCore/QuartzCore.h>

static const CGSize PHOTO_THUMBNAIL_SIZE = {60, 60};

@interface InventoryEditViewController ()

@property (strong, nonatomic) PhotoDao *photoDao;
@property (strong, nonatomic) NSMutableDictionary *tagToPickerDataDict;
@property (strong, nonatomic) NSMutableDictionary *tagToPickerViewDict;
@property (strong, nonatomic) NSMutableDictionary *tagToTextFieldDict;

@property (strong, nonatomic) IBOutlet UIToolbar *pickerToolbar;
- (IBAction)inputAccessoryViewDidFinish:(id)sender;
@property (strong, nonatomic) UITextField *currentTextField;

@property (strong, nonatomic) NSMutableArray *photoNames;
@property (strong, nonatomic) NSArray *photoViewArray;
@property (strong, nonatomic) NSArray *photoDelteButtonArray;
@property  NSUInteger currentClickPhotoIndex;
@property (strong, nonatomic) NSMutableArray *createdPhotoNames;
@property (strong, nonatomic) NSMutableArray *deletedPhotoNames;

@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;

@end

const int TAG_TITLE = 2001;
const int TAG_QUANTITY = 2002;
const int TAG_CATEGORY = 2003;
const int TAG_CONDITION = 2004;
const int TAG_PRICE = 2005;
const int TAG_SIZE = 2006;
const int TAG_WEIGHT = 2007;
const int TAG_DESCRIPTION = 2008;
const int TAG_LOCATION = 2009;
const int TAG_BARCODE = 2010;

@implementation InventoryEditViewController

@synthesize locationManager;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self)
    {
        // Custom initialization
        _tagToPickerDataDict = [NSMutableDictionary dictionary];
        [self.tagToPickerDataDict setObject:[[NSArray alloc] initWithObjects:
                                             @"", @"Book", @"DVD-Game", @"Electronics",
                                             @"Fumiture", @"Toy-Baby", nil]
                                     forKey:[NSNumber numberWithInt:TAG_CATEGORY]];
        [self.tagToPickerDataDict setObject:[[NSArray alloc] initWithObjects:
                                             @"", @"New", @"Used-good", @"Used-fair", @"Used-poor", nil]
                                     forKey:[NSNumber numberWithInt:TAG_CONDITION]];
        [self.tagToPickerDataDict setObject:[[NSArray alloc] initWithObjects:
                                             @"", @"Big", @"Small", nil]
                                     forKey:[NSNumber numberWithInt:TAG_SIZE]];
        [self.tagToPickerDataDict setObject:[[NSArray alloc] initWithObjects:
                                             @"", @"Heavy", @"Light", nil]
                                     forKey:[NSNumber numberWithInt:TAG_WEIGHT]];
        
        _tagToPickerViewDict = [NSMutableDictionary dictionary];
        _tagToTextFieldDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _photoDao = [PhotoDao instance];
    [_photoDao beginTransaction];
    
    [self prepareTextFiled:_titleTextField withTag:TAG_TITLE isPickerView:FALSE];
    [self prepareTextFiled:_barCodeTextField withTag:TAG_BARCODE isPickerView:FALSE];
    [self prepareTextFiled:_quantityTextField withTag:TAG_QUANTITY isPickerView:FALSE];
    [self prepareTextFiled:_categoryTextField withTag:TAG_CATEGORY isPickerView:TRUE];
    [self prepareTextFiled:_conditionTextField withTag:TAG_CONDITION isPickerView:TRUE];
    [self prepareTextFiled:_priceTextField withTag:TAG_PRICE isPickerView:FALSE];
    [self prepareTextFiled:_sizeTextField withTag:TAG_SIZE isPickerView:TRUE];
    [self prepareTextFiled:_weightTextField withTag:TAG_WEIGHT isPickerView:TRUE];
    
    _descriptionTextView.tag = TAG_DESCRIPTION;
    _descriptionTextView.inputAccessoryView = self.pickerToolbar;
    [_tagToTextFieldDict setObject:_descriptionTextView forKey:[NSNumber numberWithInt:TAG_DESCRIPTION]];
    _descriptionTextView.layer.borderWidth = 1.0;
    _descriptionTextView.layer.cornerRadius = 10.0;
    _descriptionTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    _photo0ImageView.userInteractionEnabled = YES;
    _photo1ImageView.userInteractionEnabled = YES;
    _photo2ImageView.userInteractionEnabled = YES;
    _photoViewArray = [[NSArray alloc] initWithObjects:_photo0ImageView, _photo1ImageView, _photo2ImageView, nil];
    _photoDelteButtonArray = [[NSArray alloc] initWithObjects:_photo0DeleteButton, _photo1DeleteButton, _photo2DeleteButton, nil];
    _photoNames = [[NSMutableArray alloc] initWithCapacity:3];
    
    _isUpdate = _inventoryItem != NULL;
    if (_isUpdate) {
        _titleTextField.text = _inventoryItem.title;
        _barCodeTextField.text = _inventoryItem.barcode;
        _quantityTextField.text = _inventoryItem.quantity.description;
        _categoryTextField.text = _inventoryItem.category;
        _conditionTextField.text = _inventoryItem.condition;
        _priceTextField.text = _inventoryItem.price.description;
        _sizeTextField.text = _inventoryItem.size;
        _weightTextField.text = _inventoryItem.weight;
        _descriptionTextView.text = _inventoryItem.desc;
        [self setLatitude:_inventoryItem.latitude AndLongitude:_inventoryItem.longitude];
        
        if (_inventoryItem.photoname1) [_photoNames addObject:_inventoryItem.photoname1];
        if (_inventoryItem.photoname2) [_photoNames addObject:_inventoryItem.photoname2];
        if (_inventoryItem.photoname3) [_photoNames addObject:_inventoryItem.photoname3];
    } else {
        [self loadInputDefault];
    }
    
    [self refreshPhotos];

    _createdPhotoNames = [[NSMutableArray alloc] init];
    _deletedPhotoNames = [[NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.title = _isUpdate?@"Save":@"Add";
    
    // Start the location manager.
    [[self locationManager] startUpdatingLocation];
}

-(void) refreshPhotos {
    bool noImage = false;
    for (int i = 0; i < _photoViewArray.count; i++) {
        UIImageView *imageView = _photoViewArray[i];
        UIButton *deleteButton = _photoDelteButtonArray[i];
        
        UIImage *image;
        if (noImage) {
            deleteButton.hidden = true;
            image = NULL;
        } else if (_photoNames.count > i) {
            image = [_photoDao getScaleImageByPhotoName:_photoNames[i]
                                            toScaleSize:PHOTO_THUMBNAIL_SIZE];
            deleteButton.hidden = false;
        } else {
            NSString* imageName = [[NSBundle mainBundle] pathForResource:@"add" ofType:@"png"];
            image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageName]];
            image = [_photoDao scaleImage:image
                                  toScale:PHOTO_THUMBNAIL_SIZE.width / image.size.width];
            deleteButton.hidden = true;
            noImage = true;
        }
        
        imageView.image = image;
        
    }
}

-(void) prepareTextFiled:(UITextField*) textField withTag:(NSUInteger) tag isPickerView:(BOOL) isPicker
{
    textField.tag = tag;
    textField.inputAccessoryView = self.pickerToolbar;
    [_tagToTextFieldDict setObject:textField forKey:[NSNumber numberWithInt:tag]];
    
    if (isPicker) {
        UIPickerView *pickerView = [[UIPickerView alloc] init];
        pickerView.dataSource = self;
        pickerView.delegate = self;
        pickerView.tag = tag;
        [pickerView setShowsSelectionIndicator:true];
        [_tagToPickerViewDict setObject:pickerView forKey:[NSNumber numberWithInt:tag]];
        
        textField.inputView = pickerView;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ReturnInput"]) {
        if (!_inventoryItem) {
            _inventoryItem = [[InventoryItemDao instance] createInventoryItem];
            _inventoryItem.createDate = [NSDate date];
        } else {
            _inventoryItem.updateDate = [NSDate date];
        }

        _inventoryItem.title = _titleTextField.text;
        _inventoryItem.barcode = _barCodeTextField.text;
        _inventoryItem.photoname1 = _photoNames.count<1 ? nil : [_photoNames objectAtIndex:0];
        _inventoryItem.photoname2 = _photoNames.count<2 ? nil : [_photoNames objectAtIndex:1];
        _inventoryItem.photoname3 = _photoNames.count<3 ? nil : [_photoNames objectAtIndex:2];
        _inventoryItem.quantity =  [NSNumber numberWithInt:[_quantityTextField.text intValue]];
        _inventoryItem.category = _categoryTextField.text;
        _inventoryItem.condition = _conditionTextField.text;
        _inventoryItem.price = [NSNumber numberWithFloat:[_priceTextField.text floatValue]];
        _inventoryItem.size = _sizeTextField.text;
        _inventoryItem.weight = _weightTextField.text;
        _inventoryItem.desc = _descriptionTextView.text;
        _inventoryItem.latitude = _latitude;
        _inventoryItem.longitude = _longitude;
        
        [self saveInputDefault];
        
        if ([[InventoryItemDao instance] saveContext]) {
            [_photoDao commit];
        } else {
            [_photoDao rollback];
        }
    } else if ([[segue identifier] isEqualToString:@"CancelInput"]) {
        [_photoDao rollback];
    }
}

// **************** Input Default Begin ****************/
- (void)saveInputDefault {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *inputDefaultDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (_conditionTextField.text) {
        [inputDefaultDict setObject:_conditionTextField.text forKey:@"condition"];
    }
    if (_categoryTextField.text) {
        [inputDefaultDict setObject:_categoryTextField.text forKey:@"category"];
    }
    [ud setObject:inputDefaultDict forKey:@"inputDefault"];
    [ud synchronize];
}
- (void)loadInputDefault {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *inputDefaultDict = [ud objectForKey:@"inputDefault"];
    if (inputDefaultDict) {
        NSString *condition = [inputDefaultDict objectForKey:@"condition"];
        if (condition) {
            _conditionTextField.text = condition;
        }
        
        NSString *category = [inputDefaultDict objectForKey:@"category"];
        if (category) {
            _categoryTextField.text = category;
        }
    }
}
// **************** Input Default End ****************/

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentTextField = textField;
    if ([textField.text length] > 0) {
        NSArray *pickerData = [self getPickerDataForViewTag:textField.tag];
        if (pickerData) {
            for (int i=0; i<pickerData.count; i++) {
                if ([[pickerData objectAtIndex:i] isEqualToString:textField.text]) {
                    UIPickerView *pickerView = [_tagToPickerViewDict
                                                objectForKey:[NSNumber numberWithInt:textField.tag]];
                    [pickerView selectRow:i inComponent:0 animated:FALSE];
                    break;
                }
            }
        }
            
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //[textField resignFirstResponder];
}

// **************** Drill Down Picker Begin ****************/

-(NSArray*)getPickerDataForViewTag:(int)tag
{
    return [_tagToPickerDataDict objectForKey:[NSNumber numberWithInt:tag]];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[self getPickerDataForViewTag:pickerView.tag] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [[self getPickerDataForViewTag:pickerView.tag] objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    UITextField *textField = [self.tagToTextFieldDict objectForKey:[NSNumber numberWithInt:pickerView.tag]];
    textField.text = [[self getPickerDataForViewTag:pickerView.tag] objectAtIndex:row];
}

/**************** Drill Down Picker Begin End ****************/

/**************** Image Picker and Barcode Scan Begin ****************/

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    if (results) {
        ZBarSymbol *symbol = nil;
        for(symbol in results)
            break;
        _barCodeTextField.text = symbol.data;
        [self queryPrice:TRUE];
        //resultImage.image = [info objectForKey: UIImagePickerControllerOriginalImage];
    } else {
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        NSString *photoName = [_photoDao addPhotoWithImage:chosenImage];
        [_photoNames addObject:photoName];
        [self refreshPhotos];
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)photoImageViewClick:(id)sender {
    UIGestureRecognizer *gestureRecongnizer = sender;
    _currentClickPhotoIndex = [_photoViewArray indexOfObject:gestureRecongnizer.view];
    if (_photoNames.count > _currentClickPhotoIndex) {
        return;
    }

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        /*
         UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
         message:@"Device has no camera. Use mock image."
         delegate:nil
         cancelButtonTitle:@"OK"
         otherButtonTitles: nil];
         
         [myAlertView show];
         */
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)touchPhotoDelete:(id)sender {
    _currentClickPhotoIndex = [_photoDelteButtonArray indexOfObject:sender];
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Remove photo"
                              message:@"Are you sure you want to remove this photo?"
                              delegate:self
                              cancelButtonTitle:@"Remove"
                              otherButtonTitles:nil];
	
	[alertView addButtonWithTitle:@"Don't remove"];
	[alertView show];
}

- (IBAction)scanBarCode:(id)sender {
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.showsZBarControls = YES;
    if([ZBarReaderController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        reader.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    [self presentViewController:reader animated:YES completion:NULL];
}

- (IBAction)retrieveItemPrice:(id)sender {
    [self queryPrice:TRUE];
}

/**************** Image Picker and Barcode Scan End ****************/

/**************** Location Manager Begin ****************/

- (CLLocationManager *)locationManager {
    
    if (locationManager != nil) {
        return locationManager;
    }
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.delegate = self;
    
    return locationManager;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    _updateLocationButton.enabled = YES;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    _updateLocationButton.enabled = NO;
}

- (IBAction)updateLocation:(id)sender {
    CLLocation *location = [locationManager location];
    if (!location) {
        return;
    }
    CLLocationCoordinate2D coordinate = [location coordinate];
    [self setLatitude:[NSNumber numberWithDouble:coordinate.latitude] AndLongitude:[NSNumber numberWithDouble:coordinate.longitude]];
}

-(void)setLatitude:(NSNumber *)latitude AndLongitude:(NSNumber *)longitude {
    _latitude = latitude;
    _longitude = longitude;
    if (_latitude && _latitude.doubleValue!=0
        && longitude && _longitude.doubleValue!=0) {
        // A number formatter for the latitude and longitude.
        static NSNumberFormatter *numberFormatter = nil;
        if (numberFormatter == nil) {
            numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [numberFormatter setMaximumFractionDigits:3];
        }
        _locationLabel.text = [NSString stringWithFormat:@"%@, %@",
                               [numberFormatter stringFromNumber:_latitude],
                               [numberFormatter stringFromNumber:_longitude]];
    } else {
        _locationLabel.text = nil;
    }
}
/**************** Location Manager End ****************/

/**************** Query Price Begin ****************/
-(void)queryPrice:(BOOL) isShowMessage {
    if ([_barCodeTextField.text length] == 0 && [_titleTextField.text length] == 0) {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Information"
                                                              message:@"Please input Bar Code or Title first."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];
        return;
    }
    
    _queryPriceButton.enabled = FALSE;
    [NSThread detachNewThreadSelector:@selector(quickPriceInBackground:)
                             toTarget:self
                           withObject:[NSNumber numberWithBool:isShowMessage]];
}

-(void)quickPriceInBackground:(NSNumber *) isShowMessage {
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:_barCodeTextField.text, @"barcode", _titleTextField.text, @"title", nil];
    
    HttpInvokerResult *result = [HttpInvoker call:@"query_item_price" WithParams:params];
    
    [self performSelectorOnMainThread:@selector(afterQueryPrice:) withObject:@[result,isShowMessage] waitUntilDone:TRUE];
}

-(void)afterQueryPrice:(NSArray*) array {
    _queryPriceButton.enabled = TRUE;
    HttpInvokerResult *result = [array objectAtIndex:0];
    NSNumber *isShowMessage = [array objectAtIndex:1];
    NSString *message = result.message;
    if (result.isOK) {
        double price = [[result.data objectForKey:@"price"] doubleValue];
        [_priceTextField setText:[NSString stringWithFormat:@"%.2f", price]];
        message = @"Query successfully.";
    }
    if (isShowMessage.boolValue) {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Information"
                                                              message:message
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];
    }
}
/**************** Query Price End ****************/

- (IBAction)inputAccessoryViewDidFinish:(id)sender {
    [_currentTextField resignFirstResponder];
    [_descriptionTextView resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
        NSString *photoName = _photoNames[_currentClickPhotoIndex];
        [_photoNames removeObjectAtIndex:_currentClickPhotoIndex];
        [_photoDao deletePhotoWithPhotoName:photoName];
        [self refreshPhotos];
	} 
}
@end

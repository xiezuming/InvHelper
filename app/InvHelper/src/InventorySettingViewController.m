//
//  InventorySettingViewController.m
//  InvHelper
//
//  Created by 谢 祖铭 on 13-9-7.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import "Constants.h"
#import "InventorySettingViewController.h"

@interface InventorySettingViewController ()

@property (strong, nonatomic) UITextField *currentTextField;
@property (strong, nonatomic) IBOutlet UIToolbar *inputToolbar;
- (IBAction)inputAccessoryViewDidFinish:(id)sender;

@end

@implementation InventorySettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _userNameTextField.inputAccessoryView = _inputToolbar;
    _passwordTextField.inputAccessoryView = _inputToolbar;
    _serverTextField.inputAccessoryView = _inputToolbar;
    _timeoutTextField.inputAccessoryView = _inputToolbar;
    _photoMaxPixelTextField.inputAccessoryView = _inputToolbar;
    _photoQualityTextField.inputAccessoryView = _inputToolbar;
    
    [self loadSettings];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)saveSettings {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    
    if (_userNameTextField.text)
        [settings setObject:_userNameTextField.text forKey:@"userName"];
    
    if (_passwordTextField.text)
        [settings setObject:_passwordTextField.text forKey:@"password"];
    
    if (_serverTextField.text)
        [settings setObject:_serverTextField.text forKey:@"server"];
    
    NSNumber *timeout = [NSNumber numberWithInt:MAX(MIN(_timeoutTextField.text.intValue, 120), 2)];
    [settings setObject:timeout forKey:KEY_TIMEOUT];
    _timeoutTextField.text = timeout.stringValue;
    
    NSNumber *photoMaxPixel = [NSNumber numberWithInt:MAX(MIN(_photoMaxPixelTextField.text.intValue, 2048), 512)];
    [settings setObject:photoMaxPixel forKey:KEY_PHOTO_MAX_PIEXEL];
    _photoMaxPixelTextField.text = photoMaxPixel.stringValue;
    
    NSNumber *photoQuality = [NSNumber numberWithFloat:MAX(MIN(_photoQualityTextField.text.floatValue, 1.0), 0.0)];
    [settings setObject:photoQuality forKey:KEY_PHOTO_QUALITY];
    _photoQualityTextField.text = photoQuality.stringValue;
    
    [ud setObject:settings forKey:@"settings"];
}

- (void)loadSettings {
    NSNumber *timeout = [NSNumber numberWithUnsignedInt:TIMEOUT_DEFAULT];
    NSNumber *photoMaxPixel = [NSNumber numberWithInt:PHOTO_MAX_SIDE_PIEXEL_DEFAULT];
    NSNumber *photoQuality = [NSNumber numberWithFloat:PHOTO_QUALITY_DEFAULT];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *settings = [ud objectForKey:KEY_SETTINGS];
    if (settings) {
        NSString *userName = [settings objectForKey:@"userName"];
        if (userName) {
            _userNameTextField.text = userName;
        }
        
        NSString *password = [settings objectForKey:@"password"];
        if (password) {
            _passwordTextField.text = password;
        }
        
        NSString *server = [settings objectForKey:@"server"];
        if (server) {
            _serverTextField.text = server;
        }
        
        if ([settings objectForKey:KEY_TIMEOUT])
            timeout = [settings objectForKey:KEY_TIMEOUT];
        
        if ([settings objectForKey:KEY_PHOTO_MAX_PIEXEL])
            photoMaxPixel = [settings objectForKey:KEY_PHOTO_MAX_PIEXEL];
        
        if ([settings objectForKey:KEY_PHOTO_QUALITY])
            photoQuality = [settings objectForKey:KEY_PHOTO_QUALITY];
    }
    _timeoutTextField.text = timeout.stringValue;
    _photoMaxPixelTextField.text = photoMaxPixel.stringValue;
    _photoQualityTextField.text = photoQuality.stringValue;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    _currentTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self saveSettings];
}

- (IBAction)inputAccessoryViewDidFinish:(id)sender {
    [_currentTextField resignFirstResponder];
}

@end

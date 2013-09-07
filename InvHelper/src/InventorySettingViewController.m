//
//  InventorySettingViewController.m
//  InvHelper
//
//  Created by 谢 祖铭 on 13-9-7.
//  Copyright (c) 2013年 Self. All rights reserved.
//

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
    if (_userNameTextField.text) {
        [settings setObject:_userNameTextField.text forKey:@"userName"];
    }
    if (_passwordTextField.text) {
        [settings setObject:_passwordTextField.text forKey:@"password"];
    }
    if (_serverTextField.text) {
        [settings setObject:_serverTextField.text forKey:@"server"];
    }
    [ud setObject:settings forKey:@"settings"];
}

- (void)loadSettings {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *settings = [ud objectForKey:@"settings"];
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
    }
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

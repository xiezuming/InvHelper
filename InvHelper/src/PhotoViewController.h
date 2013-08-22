//
//  PhotoVIewControllerViewController.h
//  Inv Helper
//
//  Created by 谢 祖铭 on 13-8-17.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MoveScaleImageView;

@interface PhotoViewController : UIViewController

@property (strong, nonatomic) NSString *photoName;
@property (strong, nonatomic) IBOutlet MoveScaleImageView *photoImageView;

@end

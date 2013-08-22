//
//  InventoryAppDelegate.h
//  InvHelper
//
//  Created by 谢 祖铭 on 13-8-17.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InventoryAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

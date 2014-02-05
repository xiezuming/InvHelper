//
//  InventoryItemDataController.h
//  Inv Helper
//
//  Created by 谢 祖铭 on 13-7-28.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InventoryItem;

@interface InventoryItemDao : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (InventoryItemDao *) instance;

- (NSUInteger)countOfList;
- (InventoryItem *)objectInListAtIndex:(NSUInteger)theIndex;
- (InventoryItem *)createInventoryItem;
- (void)removeInventoryItem:(InventoryItem *)item;
- (Boolean)saveContext;

- (void)loadAllData;

- (Boolean)exportAllDataToFile:(NSString *) fileName;

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
- (NSUInteger)countOfFilteredList;
- (InventoryItem *)objectInFilteredListAtIndex:(NSUInteger)theIndex;

@end

//
//  InventoryItemDataController.m
//  Inv Helper
//
//  Created by 谢 祖铭 on 13-7-28.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import "InventoryItemDao.h"
#import "InventoryItem.h"
#import "InventoryItemHelper.h"

const NSString *DATA_FILE_NAME = @"repo.txt";

static InventoryItemDao *instance = nil;

@interface InventoryItemDao()

@property (nonatomic, copy) NSMutableArray *invertoryItemList;
@property NSUInteger nextId;

@end

@implementation InventoryItemDao

@synthesize managedObjectContext;

- (id)init {
    if (self = [super init]) {
        return self;
    }
    return nil;
}

+ (InventoryItemDao *) instance {
    if (instance) return instance;
    
    instance = [[InventoryItemDao alloc] init];
    return instance;
}

- (NSUInteger)countOfList {
    return [self.invertoryItemList count];
}

- (InventoryItem *)objectInListAtIndex:(NSUInteger)theIndex {
    return [self.invertoryItemList objectAtIndex:theIndex];
}

- (InventoryItem *)createInventoryItem {
    InventoryItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:managedObjectContext];
    item.itemId = [NSNumber numberWithInt:_nextId++];
    [self.invertoryItemList addObject:item];
    return item;
}

- (void)removeInventoryItem:(InventoryItem *)item {
    [managedObjectContext deleteObject:item];
    if ([self saveContext]) {
        [self.invertoryItemList removeObject:item];
    }
}

- (Boolean)exportAllDataToFile:(NSString *) fileName {
    NSMutableArray *outputArray = [[NSMutableArray alloc] init];
    for (InventoryItem *item in _invertoryItemList) {
        [outputArray addObject:[InventoryItemHelper convertItemToDict:item]];
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:outputArray
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (jsonData == nil) {
        NSLog(@"Failed to output json data. %@", error.localizedDescription);
        return false;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                       , NSUserDomainMask
                                                       , YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    if ([jsonData writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
        NSLog(@"Export all data into %@", filePath);
        return true;
    } else {
        NSLog(@"Failed to write file. %@", error.localizedDescription);
        return false;
    }
}

- (void)loadAllData {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemId" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    _invertoryItemList = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (_invertoryItemList == nil) {
        NSLog(@"Failed to load data: %@", [error localizedDescription]);
        _invertoryItemList = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    if (_invertoryItemList.count > 0) {
        _nextId = [[_invertoryItemList[0] itemId] intValue] + 1;
    } else {
        _nextId = 1;
    }
}

- (Boolean)saveContext
{
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            return false;
        }
    }
    return true;
}

@end

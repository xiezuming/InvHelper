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

- (void)importDataWithArray:(NSArray*) arrayData;
- (NSArray*)exportDataToArray;

@end

@implementation InventoryItemDao

@synthesize managedObjectContext;

- (id)init {
    if (self = [super init]) {
        
        if (_invertoryItemList.count > 0) {
            _nextId = [[_invertoryItemList[0] itemId] intValue] + 1;
        } else {
            _nextId = 1;
        }
        
        return self;
    }
    return nil;
}

+ (InventoryItemDao *) getInstance {
    if (instance) return instance;
    
    instance = [[InventoryItemDao alloc] init];
    return instance;
}

- (void)setInvertoryItemList:(NSMutableArray *)newList {
    if (_invertoryItemList != newList) {
        _invertoryItemList = [newList mutableCopy];
    }
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

-(void) importDataWithArray:(NSArray*) arrayData {
    [_invertoryItemList removeAllObjects];
    
    NSUInteger maxId = 0;
    for (NSDictionary *dictData in arrayData) {
        InventoryItem *item = [InventoryItemHelper createItemWithDict:dictData];
        if (maxId < [item.itemId intValue]) {
            maxId = [item.itemId intValue];
        }
        [_invertoryItemList addObject:item];
    }
    
    _nextId = maxId + 1;
}

-(NSArray*) exportDataToArray {
    /*
    NSMutableArray *baseTypeArray = [[NSMutableArray alloc] init];
    for (InventoryItem *inventoryItem in _invertoryItemList) {
        [baseTypeArray addObject:[inventoryItem toDictionary]];
    }
    return baseTypeArray;
     */
    return nil;
}

- (void)writeData {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self exportDataToArray] options:NSJSONWritingPrettyPrinted error:&error];
    
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                       , NSUserDomainMask
                                                       , YES);
    NSString *fileName=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"repo.txt"];
    if ([jsonData writeToFile:fileName atomically:YES]) {
        NSLog(@"write data to %@", fileName);
    }
}

- (void)loadData {
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
    
    /*
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                       , NSUserDomainMask
                                                       , YES);
    NSString *fileName=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"repo.txt"];
    NSData *jsonData = [NSData dataWithContentsOfFile:fileName];
    if (jsonData) {
        NSLog(@"read data from %@", fileName);
        NSError *error;
        NSArray *arrayData = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error ];
        [self importDataWithArray:arrayData];
    }
     */
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

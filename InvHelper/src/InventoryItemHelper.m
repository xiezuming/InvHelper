//
//  InventoryItemHelper.m
//  Inv Helper
//
//  Created by 谢 祖铭 on 13-8-17.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import "InventoryItemHelper.h"
#import "InventoryItem.h"

@implementation InventoryItemHelper

+(NSDictionary*) convertItemToDict:(InventoryItem *)item {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:20];
    NSEntityDescription *entity = [item entity];
    NSDictionary *attributes = [entity attributesByName];
    
    for (NSString *attributeName in attributes) {
        id value = [item valueForKey:attributeName];
        if (value) {
            [dict setObject:[value description] forKey:attributeName];
        }
    }
    return dict;
}

@end

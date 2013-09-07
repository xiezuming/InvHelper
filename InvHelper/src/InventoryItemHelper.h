//
//  InventoryItemHelper.h
//  Inv Helper
//
//  Created by 谢 祖铭 on 13-8-17.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
@class InventoryItem;

@interface InventoryItemHelper : NSObject

+(NSDictionary*) convertItemToDict:(InventoryItem *)item KeepType:(BOOL)keepType;

@end

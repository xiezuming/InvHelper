//
//  InventoryItemHelper.m
//  Inv Helper
//
//  Created by 谢 祖铭 on 13-8-17.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import "InventoryItemHelper.h"


@implementation InventoryItemHelper

+(NSDictionary*) convertItemToDict:(InventoryItem *)item {
    /*
     _itemId = [dictData objectForKey:@"itemId"];
     _title = [dictData objectForKey:@"title"];
     _photoNames = [dictData objectForKey:@"photoNames"];
     _quantity = [dictData objectForKey:@"quantity"];
     _category = [dictData objectForKey:@"category"];
     _condition = [dictData objectForKey:@"condition"];
     _price = [dictData objectForKey:@"price"];
     _size = [dictData objectForKey:@"size"];
     _weight = [dictData objectForKey:@"weight"];
     _location = [dictData objectForKey:@"location"];
     _description = [dictData objectForKey:@"description"];
     
     return self;
     */
    return NULL;
}
+(InventoryItem*) createItemWithDict:(NSDictionary *)dict {
    /*
     NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:20];
     [dict setObject:_itemId forKey:@"itemId"];
     if (_title) [dict setObject:_title forKey:@"title"];
     if (_photoNames) [dict setObject:_photoNames forKey:@"photoNames"];
     if (_quantity) [dict setObject:_quantity forKey:@"quantity"];
     if (_category) [dict setObject:_category forKey:@"category"];
     if (_condition) [dict setObject:_condition forKey:@"condition"];
     if (_price) [dict setObject:_price forKey:@"price"];
     if (_size) [dict setObject:_size forKey:@"size"];
     if (_weight) [dict setObject:_weight forKey:@"weight"];
     if (_location) [dict setObject:_location forKey:@"location"];
     if (_description) [dict setObject:_description forKey:@"description"];
     return dict;
     */
    return NULL;
}

@end

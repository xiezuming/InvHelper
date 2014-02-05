//
//  InventoryItem.h
//  InvHelper
//
//  Created by 谢 祖铭 on 13-8-17.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface InventoryItem : NSManagedObject

@property (nonatomic, retain) NSString * barcode;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * condition;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * itemId;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * photoname1;
@property (nonatomic, retain) NSString * photoname2;
@property (nonatomic, retain) NSString * photoname3;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * weight;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSDate * updateDate;

@end

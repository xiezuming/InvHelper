//
//  PhotoDao.h
//  Inv Helper
//
//  Created by 谢 祖铭 on 13-8-10.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoDao : NSObject

+ (PhotoDao *) instance;

-(UIImage *)getImageByPhotoName:(NSString*) photoName;

-(UIImage *)getScaleImageByPhotoName:(NSString *)photoName
                          toScaleSize:(CGSize)size;
-(UIImage *)scaleImage:(UIImage *)image
                toScale:(float)scaleSize;

-(NSString *)addPhotoWithImage:(UIImage *)image;
-(void)deletePhotoWithPhotoName:(NSString *)photoName;

-(void)beginTransaction;
-(void)commit;
-(void)rollback;

@end

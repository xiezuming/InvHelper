//
//  PhotoDao.m
//  Inv Helper
//
//  Created by 谢 祖铭 on 13-8-10.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import "Constants.h"
#import "PhotoDao.h"

static PhotoDao *instance = nil;

@interface PhotoDao ()

@property (strong, nonatomic) NSMutableArray *addedPhotoPaths;
@property (strong, nonatomic) NSMutableArray *deletedPhotoPaths;

@end

@implementation PhotoDao

+ (PhotoDao *) instance {
    if (instance) return instance;
    
    instance = [[PhotoDao alloc] init];
    return instance;
}

-(NSString *) getPhotoPath:(NSString *) photoName {
    NSString *basePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                               , NSUserDomainMask
                                                               , YES) objectAtIndex:0]
                          stringByAppendingPathComponent:@"pic"];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:basePath]) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:basePath
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error]) {
            NSLog(@"Failed to create photo base directory: %@", [error localizedDescription]);
        }
        
    }
    
    return [basePath stringByAppendingPathComponent:photoName];
}

-(UIImage *) getImageByPhotoName:(NSString *)photoName {
    if (!photoName) {
        return NULL;
    }
    
    NSString *filePath = [self getPhotoPath:photoName];
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    return [UIImage imageWithData:imageData];
}

-(UIImage *) getScaleImageByPhotoName:(NSString *)photoName
                          toScaleSize:(CGSize)size {
    UIImage *image = [self getImageByPhotoName:photoName];
    if (image) {
        float scaleW = size.width / image.size.width;
        float scaleH = size.height / image.size.height;
        float scale = scaleW < scaleH ? scaleW : scaleH;
        image = [self scaleImage:image toScale:scale];
    }
    return image;
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize

{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
                                
-(NSString *) addPhotoWithImage:(UIImage *)image {
    UIImage *scaledImage = [self scaleImageFitSettings:image];
    CGFloat compressionQuality = [self getPhotoQuality];
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *photoName = [NSString stringWithFormat:@"%d.jpg", (int)timeStamp];
    NSString *filePath = [self getPhotoPath:photoName];
    
    [UIImageJPEGRepresentation(scaledImage, compressionQuality) writeToFile:filePath atomically:YES];
    [_addedPhotoPaths addObject:filePath];
    NSLog(@"Add photo:  %@", filePath);
    
    return photoName;
}

-(UIImage *) scaleImageFitSettings:(UIImage *) orignalImage {
    CGFloat photoMaxSidePiexel = PHOTO_MAX_SIDE_PIEXEL_DEFAULT;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *settings = [ud objectForKey:KEY_SETTINGS];
    if (settings) {
        NSNumber *photoMaxSidePiexelSetting = [settings objectForKey:KEY_PHOTO_MAX_PIEXEL];
        if (photoMaxSidePiexelSetting)
            photoMaxSidePiexel = photoMaxSidePiexelSetting.floatValue;
    }
    CGFloat scaleW = photoMaxSidePiexel / orignalImage.size.width;
    CGFloat scaleH = photoMaxSidePiexel / orignalImage.size.height;
    CGFloat scaleSize = MIN(scaleW, scaleH);
    if (scaleSize < 1)
        return [self scaleImage:orignalImage toScale:scaleSize];
    else
        return orignalImage;
}

-(CGFloat) getPhotoQuality {
    CGFloat photoQuality = PHOTO_QUALITY_DEFAULT;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *settings = [ud objectForKey:KEY_SETTINGS];
    if (settings) {
        NSNumber *photoQualitySetting = [settings objectForKey:KEY_PHOTO_QUALITY];
        if (photoQualitySetting)
            photoQuality = photoQualitySetting.floatValue;
    }
    return photoQuality;
}

-(void)deletePhotoWithPhotoName:(NSString *)photoName {
    NSString *filePath = [self getPhotoPath:photoName];
    [_deletedPhotoPaths addObject:filePath];
    NSLog(@"Delete photo:  %@", filePath);
}

-(void)beginTransaction {
    _addedPhotoPaths = [[NSMutableArray alloc] init];
    _deletedPhotoPaths = [[NSMutableArray alloc] init];
}

-(void)commit {
    [self removeFiles:_deletedPhotoPaths];
    [_addedPhotoPaths removeAllObjects];
    [_deletedPhotoPaths removeAllObjects];
}

-(void)rollback {
    [self removeFiles:_addedPhotoPaths];
    [_addedPhotoPaths removeAllObjects];
    [_deletedPhotoPaths removeAllObjects];
}

-(void)removeFiles:(NSArray *) filePaths {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (NSString *filePath in filePaths) {
        BOOL success = [fileManager removeItemAtPath:filePath error:NULL];
        NSLog(@"Remove file: %@, file = %@", success ? @"YES" : @"NO", filePath);
    }
}
@end

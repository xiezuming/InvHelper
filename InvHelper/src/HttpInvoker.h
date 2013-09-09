//
//  HttpInvoker.h
//  InvHelper
//
//  Created by 谢 祖铭 on 13-9-7.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpInvokerResult : NSObject

@property (readonly) BOOL isOK;
@property (readonly, nonatomic, retain) NSString * message;
@property (readonly, nonatomic, retain) NSDictionary * data;

+(id) createSuccessfulResultWithData:(NSDictionary *)data;
+(id) createFialedResultWithMessage:(NSString *)message;

@end

@interface HttpInvoker : NSObject

+(HttpInvokerResult *) call:(NSString *)methodName WithParams:(NSDictionary *) params;
+(HttpInvokerResult *) uploadFile:(NSString *)filePath WithParams:(NSDictionary *) params;

@end


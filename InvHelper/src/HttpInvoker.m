//
//  HttpInvoker.m
//  InvHelper
//
//  Created by 谢 祖铭 on 13-9-7.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import "HttpInvoker.h"

@implementation HttpInvokerResult

@synthesize isOK;
@synthesize message;
@synthesize data;

-(id) init:(BOOL) isOKIn :(NSString *) messageIn :(NSDictionary *) dataIn {
    self = [super init];
    if (self != nil) {
        isOK = isOKIn;
        message = messageIn;
        data = dataIn;
    }
    return self;
}

+(id) createSuccessfulResultWithData:(NSDictionary *)dataIn {
    return [[HttpInvokerResult alloc] init:true :nil :dataIn];
}

+(id) createFialedResultWithMessage:(NSString *)messageIn {
    return [[HttpInvokerResult alloc] init:false :messageIn :nil];
}

@end

@implementation HttpInvoker

+(HttpInvokerResult *) call:(NSString *)methodName WithParams:(NSDictionary *) params {
    NSString *server;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *settings = [ud objectForKey:@"settings"];
    if (settings) {
        server = [settings objectForKey:@"server"];
    }
    if (!settings || [server length] == 0) {
        return [HttpInvokerResult createFialedResultWithMessage:@"Input the server address in Settings first"];
    }
    
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://%@/inv/index.php/inv/%@", server, methodName]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:5.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[HttpInvoker convertToHttpBodyWithParams:params]];
    
    NSError *error;
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (!received) {
        return [HttpInvokerResult createFialedResultWithMessage:[error localizedDescription]];
    }
    NSLog(@"resutl=%@",[[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding]);
    
    NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:received options:kNilOptions error:&error];
    if (!resultJSON) {
        return [HttpInvokerResult createFialedResultWithMessage:@"Interanl Error."];
    }
    
    if ([[resultJSON objectForKey:@"result"] intValue] > 0) {
        return [HttpInvokerResult createSuccessfulResultWithData:[resultJSON objectForKey:@"data"]];
    } else {
        return [HttpInvokerResult createFialedResultWithMessage:[resultJSON objectForKey:@"message"]];
    }
}

+(NSData *) convertToHttpBodyWithParams:(NSDictionary *) params {
    NSString *body = @"";
    for (NSString *key in params) {
        if ([body length] > 0) body = [body stringByAppendingString:@"&"];
        
        id object = [params objectForKey:key];
        NSString *objectStr;
        if ([object isKindOfClass:[NSDate class]]) {
            NSDate *date = object;
            objectStr = [[NSNumber numberWithLong:[date timeIntervalSince1970]] stringValue]; ;
        } else {
            objectStr = [object description];
        }
        
        body = [NSString stringWithFormat:@"%@%@=%@", body, [key description], objectStr];
    };
    NSLog(@"body = %@", body);
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}

@end


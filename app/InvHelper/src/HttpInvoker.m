//
//  HttpInvoker.m
//  InvHelper
//
//  Created by 谢 祖铭 on 13-9-7.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import "HttpInvoker.h"
#import "Constants.h"

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

+(id) createSuccessfulResultWithMessage:(NSString *)messageIn {
    return [[HttpInvokerResult alloc] init:true :messageIn :nil];
}

+(id) createFialedResultWithMessage:(NSString *)messageIn {
    return [[HttpInvokerResult alloc] init:false :messageIn :nil];
}

@end

@implementation HttpInvoker

+(HttpInvokerResult *) call:(NSString *)methodName WithParams:(NSDictionary *) params {
    NSString *baseUrlString = [HttpInvoker getBaseUrlString];
    if (!baseUrlString) {
        return [HttpInvokerResult createFialedResultWithMessage:@"Input the server address in Settings first"];
    }
    
    NSURL *url = [NSURL URLWithString:[baseUrlString stringByAppendingString:methodName]];
    NSTimeInterval timeout = [HttpInvoker getTimeout];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:timeout];
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

+(NSString *) getBaseUrlString {
    NSString *server;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *settings = [ud objectForKey:@"settings"];
    if (settings) {
        server = [settings objectForKey:@"server"];
    }
    if (!settings || [server length] == 0) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"http://%@/inv/index.php/inv/", server];
}

+(NSTimeInterval) getTimeout {
    NSNumber *timeout = NULL;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *settings = [ud objectForKey:KEY_SETTINGS];
    if (settings) {
        timeout = [settings objectForKey:KEY_TIMEOUT];
    }
    if (!settings) {
        timeout = [NSNumber numberWithUnsignedInt:TIMEOUT_DEFAULT];
    }
    return timeout.doubleValue;
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

+(HttpInvokerResult *) uploadFile:(NSString *)filePath WithParams:(NSDictionary *) params {
    NSString *baseUrlString = [HttpInvoker getBaseUrlString];
    if (!baseUrlString) {
        return [HttpInvokerResult createFialedResultWithMessage:@"Input the server address in Settings first"];
    }
    
    NSURL *url = [NSURL URLWithString:[baseUrlString stringByAppendingString:@"upload"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:120];
    [request setHTTPMethod: @"POST"];
    
    // set Content-Type in HTTP header
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    NSString* fileName = [filePath lastPathComponent];
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%ld", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
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

@end


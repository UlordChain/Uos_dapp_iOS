//
//  YCHttpTool.h
//  UIP
//
//  Created by th on 2018/3/1.
//  Copyright © 2018年 thgyuip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface YCHttpTool : NSObject

/**
 get请求
 */
+ (NSURLSessionDataTask *)getMethod:(NSString *)url parameter:(NSDictionary *)dic result:(void(^)(id content,id err))result;
/**
 post请求
 */
+ (NSURLSessionDataTask *)postMethod:(NSString *)url parameter:(NSDictionary *)dic result:(void(^)(id content,id err))result;

@end

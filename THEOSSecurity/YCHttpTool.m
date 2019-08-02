//
//  YCHttpTool.m
//  UIP
//
//  Created by th on 2018/3/1.
//  Copyright © 2018年 thgyuip. All rights reserved.
//

#import "YCHttpTool.h"

@implementation YCHttpTool


/**
 get请求

 @param url 地址
 @param dic 参数集合
 @param result 结果回调
 @return 请求对象
 */
+ (NSURLSessionDataTask *)getMethod:(NSString *)url parameter:(NSDictionary *)dic result:(void (^)(id content, id err))result
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //申明返回的结果是json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //申明请求的数据是json类型
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30;
    //如果报接受类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/plain", @"application/json", @"text/json", nil];
    return [manager GET:url
        parameters:dic
        progress:nil
        success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
            if (result) {
                NSLog(@"getMethod url: %@", url);
                NSLog(@"getMethod response: %@", responseObject);
                result(responseObject, nil);
            }
        }
        failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
            if (result) {
                NSLog(@"getMethod url: %@", url);
                NSLog(@"getMethod error: %@", error);
                result(nil, error);
            }
        }];
}


/**
 post请求

 @param url 地址
 @param dic 参数集合
 @param result 结果回调
 @return 请求对象
 */
+ (NSURLSessionDataTask *)postMethod:(NSString *)url parameter:(NSDictionary *)dic result:(void (^)(id content, id err))result
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //申明返回的结果是json类型
    manager.responseSerializer                = [AFJSONResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 120;
    //申明请求的数据是json类型
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //如果报接受类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes =
        [NSSet setWithObjects:@"text/html", @"text/plain", @"application/json", @"text/json", @"text/javascript", nil];
    NSLog(@"postMethod url: %@", url);
    if (dic) {
        NSLog(@"postMethod params: %@", dic);
    }
    return [manager POST:url
        parameters:dic
        progress:nil
        success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
            if (result) {
                NSLog(@"postMethod url: %@", url);
                NSLog(@"postMethod response: %@", responseObject);
                result(responseObject, nil);
            }
        }
        failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
            if (result) {
                NSLog(@"postMethod url: %@", url);
                NSLog(@"postMethod error: %@", error);
                result(nil, error);
            }
        }];
}

@end

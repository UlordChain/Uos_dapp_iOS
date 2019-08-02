//
//  SignYC.m
//  Oth
//
//  Created by th on 2018/6/13.
//  Copyright © 2018年 thgyuip. All rights reserved.
//

#import "THEOSSignManager.h"

#import "ripemd160.h"
#import "NSData+Hash.h"
#import "NSString+Base58.h"

#import "EosByteWriter.h"
#import "EOS_Key_Encode.h"
#import "Sha256.h"
#import "uECC.h"
#import "NSObject+Extension.h"
#import "NSDate+ExFoundation.h"

#import "libbase58.h"

#import "rmd160.h"
#import "JavascriptWebViewController.h"
#import "THEOSManager.h"

@implementation THEOSSignManager

#pragma mark - 创建签名
+ (NSString *)signVC:(UIViewController *)vc
             ChainId:(NSString *)chainId
          privateKey:(NSString *)privateKey
    Ref_block_prefix:(NSString *)ref_block_prefix
       ref_block_num:(NSString *)ref_block_num
          expiration:(NSString *)expiration
                data:(NSString *)data
             twoData:(NSString *)twoData
           threeData:(NSString *)threeData
         eosTransfer:(BOOL)eosTransfer
                name:(NSString *)name
                  to:(NSString *)to
                 num:(NSString *)num
                text:(NSString *)text
              finish:(void (^)(id content, id error))finish
{
    JavascriptWebViewController *webVC = [[JavascriptWebViewController alloc] init];
    // webVC.view.frame = vc.view.bounds;
    webVC.view.frame = CGRectZero;

    [vc addChildViewController:webVC];
    [vc.view addSubview:webVC.view];

    //签名部分在这儿
    __block NSString *txData  = nil;
    __weak typeof(webVC) webv = webVC;
    webVC.finish              = ^(NSString *sth) {
        NSData *data      = [sth base58ToData];
        NSString *signStr = [self toEOSSignature:data];
        if (signStr) {
            finish(@[ signStr, txData ?: @"--" ], nil);
        }
        else {
            finish(nil, @"error");
        }

        [webv removeFromParentViewController];
    };

    NSDictionary *dic = [self parametersRef_block_prefix:ref_block_prefix
                                           ref_block_num:ref_block_num
                                              expiration:expiration
                                                    data:data
                                                 twoData:twoData
                                               threeData:threeData
                                             eosTransfer:eosTransfer
                                                    name:name
                                                      to:to
                                                     num:num
                                                    text:text];

    NSData *writerData = nil;
    if (eosTransfer) {
        writerData = [EosByteWriter getBytesForSignature2:[NSObject convertHexStrToData:chainId]
                                                andParams:dic
                                              andCapacity:255
                                                    block:^(NSString *data) {
                                                        txData = data;
                                                    }];
    }
    else {
        writerData = [EosByteWriter getBytesForSignature:[NSObject convertHexStrToData:chainId] andParams:dic andCapacity:255];
    }

    writerData        = writerData.SHA256;
    NSString *snjjStr = [NSString hexWithData:writerData];
    [webVC sign:snjjStr prikey:privateKey];
    return nil;
}

+ (void)signWithVC:(UIViewController *)vc ChainId:(NSString *)chainId privateKey:(NSString *)privateKey body:(NSDictionary *)body finish:(void(^)(id content,id error))finish {
    JavascriptWebViewController *webVC = [[JavascriptWebViewController alloc] init];
    webVC.view.frame = CGRectZero;
    [vc addChildViewController:webVC];
    [vc.view addSubview:webVC.view];
    //签名部分在这儿
    __block NSString *txData  = nil;
    __weak typeof(webVC) webv = webVC;
    webVC.finish              = ^(NSString *sth) {
        NSData *data      = [sth base58ToData];
        NSString *signStr = [self toEOSSignature:data];
        if (signStr) {
            finish(@[ signStr, txData ?: @"--" ], nil);
        }
        else {
            finish(nil, @"error");
        }
        
        [webv removeFromParentViewController];
    };
    
    NSDictionary *dic = body;
    
    NSData *writerData = [EosByteWriter getBytesForSignature:[NSObject convertHexStrToData:chainId]
                                                andParams:dic
                                              andCapacity:255];
    
    writerData        = writerData.SHA256;
    NSString *snjjStr = [NSString hexWithData:writerData];
    [webVC sign:snjjStr prikey:privateKey];
}

+ (NSString *)toEOSSignature:(NSData *)data
{
    NSString *EOS_PREFIX = @"SIG_K1_";
    NSMutableData *temp  = [NSMutableData new];
    [temp appendData:data];
    [temp appendData:[@"K1" dataUsingEncoding:NSUTF8StringEncoding]];

    NSMutableData *stream = [NSMutableData new];
    [stream appendData:data];
    [stream appendData:[temp.RMD160 subdataWithRange:NSMakeRange(0, 4)]];
    return [EOS_PREFIX stringByAppendingString:[NSString base58WithData:stream]];
}

+ (NSDictionary *)parametersRef_block_prefix:(NSString *)ref_block_prefix
                               ref_block_num:(NSString *)ref_block_num
                                  expiration:(NSString *)expiration
                                        data:(NSString *)data
                                     twoData:(NSString *)twoData
                                   threeData:(NSString *)threeData
                                 eosTransfer:(BOOL)eosTransfer
                                        name:(NSString *)name
                                          to:(NSString *)to
                                         num:(NSString *)num
                                        text:(NSString *)text
{
    NSDictionary *dic = nil;
    if (eosTransfer) {
        dic = @{
            @"ref_block_num" : ref_block_num,
            @"ref_block_prefix" : ref_block_prefix,
            @"expiration" : expiration,
            @"actions" : @[ @{@"account" : @"uosio.token", @"authorization" : @[ @{@"actor" : name, @"permission" : @"active"} ], @"name" : @"transfer"} ],
            @"signatures" : @[],
            @"to" : to,
            @"quantity" : num,
            @"text" : text,
            @"from" : name,
            @"data" : data
        };
    }
    else {
        dic = @{
            @"ref_block_num" : ref_block_num,
            @"ref_block_prefix" : ref_block_prefix,
            @"expiration" : expiration,
            @"actions" : @[
                @{@"account" : @"uosio.token", @"name" : @"newaccount", @"authorization" : @[ @{@"actor" : name, @"permission" : @"active"} ], @"data" : data},
                @{
                   @"account" : @"uosio.token",
                   @"name" : @"buyrambytes",
                   @"authorization" : @[ @{@"actor" : name, @"permission" : @"active"} ],
                   @"data" : twoData
                },
                @{@"account" : @"uosio", @"name" : @"delegatebw", @"authorization" : @[ @{@"actor" : name, @"permission" : @"active"} ], @"data" : threeData}
            ],
            @"signatures" : @[]
        };
    }
    NSLog(@"待签名数据: %@", dic);
    return dic;
}

+ (NSString *)th_TansactionSignWithController:(UIViewController *)vc
                                       priKey:(NSString *)priKey
                                      chainId:(NSString *)chainId
                                       params:(NSDictionary *)params
                                       finish:(void (^)(id content, id error))finish
{
    JavascriptWebViewController *webVC = [[JavascriptWebViewController alloc] init];
    webVC.view.frame                   = CGRectZero;
    [vc addChildViewController:webVC];
    [vc.view addSubview:webVC.view];

    //签名部分在这儿
    __block NSString *txData  = nil;
    __weak typeof(webVC) webv = webVC;
    webVC.finish              = ^(NSString *sth) {
        NSData *data      = [sth base58ToData];
        NSString *signStr = [self toEOSSignature:data];
        if (signStr) {
            finish(@[ signStr, txData ?: @"--" ], nil);
        }
        else {
            finish(nil, @"error");
        }
        [webv removeFromParentViewController];
    };

    NSData *writerData = nil;
    writerData         = [EosByteWriter getBytesForSignature:[NSObject convertHexStrToData:chainId] andParams:params andCapacity:64];

    writerData        = writerData.SHA256;
    NSString *snjjStr = [NSString hexWithData:writerData];
    [webVC sign:snjjStr prikey:priKey];
    return nil;
}

@end

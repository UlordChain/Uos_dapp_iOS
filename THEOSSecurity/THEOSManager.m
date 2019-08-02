//
//  THEOSManager.m
//  Ulrd
//
//  Created by tangwei on 2018/8/27.
//  Copyright © 2018年 Tianhe Guoyun Technology Co., Ltd. All rights reserved.
//

#import "THEOSManager.h"
#import "THEOSSignManager.h"
#import "EosPrivateKey.h"
#import "NSObject+Extension.h"

@interface NSString (THEOS)

- (NSString *)th_eos_expiration:(NSInteger)addtime ;

@end


@interface THEOSDataStructure : NSObject
@end

@implementation THEOSDataStructure

/// 签名数据
+ (NSDictionary *)__sign_data_with_blockNum:(NSString *)blockNum blockPrefix:(NSString *)blockPrefix expiration:(NSString *)expiration actor:(NSString *)actor data:(NSString *)binData actionName:(NSString *)actionName {
    NSArray *ns = @[
                           @{
                               @"account":@"uosio",
                               @"name":actionName?:@"",
                               @"authorization":@[
                                       @{
                                           @"actor":actor?:@"",
                                           @"permission":@"active"
                                           }
                                       ],
                               @"data":binData?:@""
                               }
                           ];
    return [self __sign_data_actions_with_blockNum:blockNum blockPrefix:blockPrefix expiration:expiration actions:ns];
}

/// 签名数据
+ (NSDictionary *)__sign_data_actions_with_blockNum:(NSString *)blockNum blockPrefix:(NSString *)blockPrefix expiration:(NSString *)expiration actions:(NSArray *)actions {
    NSDictionary *dict = @{
                           @"ref_block_num": blockNum?:@"",
                           @"ref_block_prefix": blockPrefix?:@"",
                           @"expiration": expiration?:@"",
                           @"actions": actions?:@"",
                           @"signatures": @[]
                           };;
    NSLog(@"签名数据：%@", dict);
    return dict;
}

/// push 数据
+ (NSDictionary *)__sign_push_data_with_blockNum:(NSString *)blockNum blockPrefix:(NSString *)blockPrefix expiration:(NSString *)expiration actor:(NSString *)actor data:(NSString *)binData sign:(NSString *)sign actionName:(NSString *)actionName {
    NSArray *actions = @[
                         @{
                             @"account": @"uosio",
                             @"authorization": @[
                                     @{
                                         @"actor": actor?:@"",
                                         @"permission": @"active"
                                         }
                                     ],
                             @"data": binData?:@"",
                             @"name": actionName?:@""
                             }
                         ];
    return [self __sign_push_data_with_blockNum:blockNum blockPrefix:blockPrefix expiration:expiration sign:sign actions:actions];
}

/// 交易数据
+ (NSDictionary *)__sign_push_data_with_blockNum:(NSString *)blockNum blockPrefix:(NSString *)blockPrefix expiration:(NSString *)expiration sign:(NSString *)sign actions:(NSArray *)actions {
    NSDictionary* dict = @{
                           @"compression": @"none",
                           @"signatures": @[sign?:@""],
                           @"transaction": @{
                                   @"actions": actions?:@"",
                                   @"delay_sec":@0,
                                   @"expiration": expiration?:@"",
                                   @"max_cpu_usage_ms":@0,
                                   @"net_usage_words":@0,
                                   @"ref_block_num": blockNum?:@"",
                                   @"ref_block_prefix": blockPrefix?:@"",
                                   @"context_free_actions":@[]
                                   }
                           };
    NSLog(@"交易数据：%@", dict);
    return dict;
}

@end

@implementation NSString (THEOS)

/// 2018-08-30T12:15:19
/// time formate string
- (NSString *)th_eos_expiration:(NSInteger)addtime {
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    [dataFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    NSDate *tmpDate = [dataFormatter dateFromString:self];
    NSString *timeStr = [NSString stringWithFormat:@"%ld",(long)[tmpDate timeIntervalSince1970]];
    tmpDate = [NSDate dateWithTimeIntervalSince1970:[timeStr integerValue] + addtime];
    [dataFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    return [dataFormatter stringFromDate:tmpDate];
}

/// 1535631319
/// timeStamp
- (NSString *)th_eos_sign_expiration:(NSInteger)addtime {
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    NSString *timeLocal = [NSString stringWithFormat:@"%@",localZone];
    timeLocal = [[timeLocal componentsSeparatedByString:@"(GMT"] lastObject];
    timeLocal = [[timeLocal componentsSeparatedByString:@") offset"] firstObject];
    NSInteger time = [timeLocal integerValue];
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    [dataFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    NSDate *tmpDate = [dataFormatter dateFromString:self];
    NSString *timeStr = [NSString stringWithFormat:@"%ld",(long)[tmpDate timeIntervalSince1970] + addtime + time * 3600];
    return timeStr;
}

- (NSString *)th_eos_scan_sign_expiration:(NSInteger)addtime {
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    NSString *timeLocal = [NSString stringWithFormat:@"%@",localZone];
    timeLocal = [[timeLocal componentsSeparatedByString:@"(GMT"] lastObject];
    timeLocal = [[timeLocal componentsSeparatedByString:@") offset"] firstObject];
    NSInteger time = [timeLocal integerValue];
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    [dataFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *tmpDate = [dataFormatter dateFromString:self];
    NSString *timeStr = [NSString stringWithFormat:@"%ld",(long)[tmpDate timeIntervalSince1970] + addtime + time * 3600];
    return timeStr;
}

@end


@implementation THEOSManager

+ (NSString *)__baseUrl {
    return @"https://testrpc1.uosio.org:20580/";
}

+ (void)th_scan_tranfer_data:(NSDictionary *)dict pk:(NSString *)pk complete:(THEOSRequestCompleteBlock)complete {
    __block NSString *__block_num = nil;
    __block NSString *__block_id = nil;
    __block NSString *__block_prefix = nil;
    __block NSString *__expiration = nil;
    __block NSString *__chainID = nil;
    __block NSError *__error = nil;
    
    dispatch_group_t group = dispatch_group_create();
    NSMutableArray *mArray = ((NSArray *)dict[@"actions"]).mutableCopy;
    for (int i = 0;i < mArray.count; i++) {
        NSDictionary *action = mArray[i];
        dispatch_group_enter(group);
        [THEOSManager __th_src_to_bin:action[@"account"] action:action[@"name"] args:action[@"data"] complete:^(id rslt, NSError *error) {
            if (!__error) {
                __error = error;
            }
            if (rslt) {
                NSMutableDictionary *md = action.mutableCopy;
                md[@"data"] = rslt;
                [mArray replaceObjectAtIndex:i withObject:md.copy];
            }
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_enter(group);
    [THEOSManager __th_get_info_block:^(id rslt, NSError *error) {
        if (!__error) {
            __error = error;
        }
        if (!__error) {
            __block_num = [NSString stringWithFormat:@"%@", rslt[@"blockNum"]];
            __block_id = rslt[@"id"];
            __block_prefix = [NSString stringWithFormat:@"%@",rslt[@"ref_block_prefix"]];
            __expiration = rslt[@"timestamp"];
            __chainID = rslt[@"chain_id"];
        }
        dispatch_group_leave(group);
    }];
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (__error) {
            complete(nil, __error);
            return ;
        }
        NSString *exp = dict[@"expiration"];
        if (exp.length <= 0) {
            exp = [__expiration th_eos_expiration:60];
        }
        NSDictionary *body = [THEOSDataStructure __sign_data_actions_with_blockNum:__block_num blockPrefix:__block_prefix expiration:[exp th_eos_scan_sign_expiration:0] actions:mArray];
        [THEOSSignManager signWithVC:vc ChainId:__chainID privateKey:pk body:body finish:^(id content, id error) {
            if (content) {
                NSString *signStr = [content firstObject];
                NSDictionary *dc = [THEOSDataStructure __sign_push_data_with_blockNum:__block_num blockPrefix:__block_prefix expiration:exp sign:signStr actions:mArray];
                [THEOSManager __th_post_transaction:dc complete:^(id rslt, NSError *error) {
                    if (error) {
                        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
                        NSString *st = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        NSLog(@"error: %@", st);
                    }
                    complete(rslt, error);
                }];
            }
        }];
    });
}

+ (void)th_scan_sign_data:(NSDictionary *)dict pk:(NSString *)pk complete:(THEOSRequestCompleteBlock)complete {
    __block NSString *__block_num = nil;
    __block NSString *__block_id = nil;
    __block NSString *__block_prefix = nil;
    __block NSString *__expiration = nil;
    __block NSString *__chainID = nil;
    __block NSError *__error = nil;
    
    dispatch_group_t group = dispatch_group_create();
    NSMutableArray *mArray = ((NSArray *)dict[@"actions"]).mutableCopy;
    for (int i = 0;i < mArray.count; i++) {
        NSDictionary *action = mArray[i];
        dispatch_group_enter(group);
        [THEOSManager __th_src_to_bin:action[@"account"] action:action[@"name"] args:action[@"data"] complete:^(id rslt, NSError *error) {
            if (!__error) {
                __error = error;
            }
            if (rslt) {
                NSMutableDictionary *md = action.mutableCopy;
                md[@"data"] = rslt;
                [mArray replaceObjectAtIndex:i withObject:md.copy];
            }
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_enter(group);
    [THEOSManager __th_get_info_block:^(id rslt, NSError *error) {
        if (!__error) {
            __error = error;
        }
        if (!__error) {
            __block_num = [NSString stringWithFormat:@"%@", rslt[@"blockNum"]];
            __block_id = rslt[@"id"];
            __block_prefix = [NSString stringWithFormat:@"%@",rslt[@"ref_block_prefix"]];
            __expiration = rslt[@"timestamp"];
            __chainID = rslt[@"chain_id"];
        }
        dispatch_group_leave(group);
    }];
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (__error) {
            complete(nil, __error);
            return ;
        }
        NSString *exp = dict[@"expiration"];
        if (!exp) {
            exp = [__expiration th_eos_expiration:60];
        }
        NSDictionary *body = [THEOSDataStructure __sign_data_actions_with_blockNum:__block_num blockPrefix:__block_prefix expiration:[exp th_eos_scan_sign_expiration:0] actions:mArray];
        [THEOSSignManager signWithVC:vc ChainId:__chainID privateKey:pk body:body finish:^(id content, id error) {
            if (content) {
                NSString *signStr = [content firstObject];
                NSDictionary *dc = [THEOSDataStructure __sign_push_data_with_blockNum:__block_num blockPrefix:__block_prefix expiration:exp sign:signStr actions:mArray];
                complete(dc, error);
            }
        }];
    });
}

/// 转账
+ (void)__th_push_transaction_data:(NSString *)compression sign:(NSString *)sign name:(NSString *)name
                            data:(NSString *)data expiration:(NSString *)expiration
                       block_num:(NSString *)block_num block_prefix:(NSString *)block_prefix complete:(THEOSRequestCompleteBlock)complete {
    NSDictionary *dic = @{
            @"compression": compression.length>0?compression:@"none",
            @"signatures": @[sign?:@""],
            @"transaction": @{
                    @"actions": @[
                            @{
                                @"account": @"uosio.token",
                                @"authorization": @[
                                        @{
                                            @"actor": name?:@"",
                                            @"permission": @"active"
                                            }
                                        ],
                                @"data": data?:@"",
                                @"name": @"transfer"
                                }
                            ],
                    @"delay_sec":@0,
                    @"expiration": expiration?:@"",
                    @"max_cpu_usage_ms":@0,
                    @"net_usage_words":@0,
                    @"ref_block_num": block_num?:@"",
                    @"ref_block_prefix": block_prefix?:@"",
                    @"context_free_actions":@[]
                    }
            };
    [THEOSManager __th_post_transaction:dic complete:complete];
}

/// 交易 json to bin
+ (void)__th_transfer_json_to_bin:(NSString *)from to:(NSString *)to amount:(NSString *)amount comment:(NSString *)comment complete:(THEOSRequestCompleteBlock)complete {
    NSDictionary *args = @{
                           @"from": from?:@"",//执行者名称
                           @"to": to?:@"",//抵押者
                           @"quantity": [NSString stringWithFormat:@"%.4f %@", amount.floatValue, @"UOS"],//算法处理过后的转账金额
                           @"memo": comment?:@"" //转账备注
                           };
    [self __th_src_to_bin:@"uosio.token" action:@"transfer" args:args complete:complete];
}

+ (void)__th_src_to_bin:(NSString *)code action:(NSString *)action args:(NSDictionary *)args complete:(THEOSRequestCompleteBlock)complete {
    NSDictionary *dic = @{
                          @"code": code?:@"",//合约账户（需要特别注意默认eosio.token）
                          @"action": action?:@"",//抵押（默认transfer）
                          @"args": args?:@{}
                          };
    [THEOSManager __th_json_to_bin:dic complete:complete];
}

/// 获取最新区块及区块信息
+ (void)__th_get_info_block:(THEOSRequestCompleteBlock)complete {
    [THEOSManager __th_getInfo:^(id rslt, NSError *error) {
        if (error) {
            complete(nil, error);
            return ;
        }
        NSNumber *blockNum = rslt[@"head_block_num"];
        NSString *chainID = rslt[@"chain_id"];

        [THEOSManager __th_getBlockInfo:blockNum.stringValue complete:^(id rslt, NSError *error) {
            if (error) {
                complete(nil,error);
                return;
            }
            NSMutableDictionary *dict = ((NSDictionary *)rslt).mutableCopy;
            dict[@"chain_id"] = chainID;
            dict[@"blockNum"] = [blockNum stringValue];
            complete(dict, nil);
        }];
    }];
}

/// 获取最新区块的具体信息
+ (void)__th_getBlockInfo:(NSString *)block complete:(THEOSRequestCompleteBlock)complete {
    NSString *url = [NSString stringWithFormat:@"%@%@",[self __baseUrl],@"v1/chain/get_block"];
    NSDictionary *dic = @{@"block_num_or_id":block};
    [YCHttpTool postMethod:url parameter:dic result:complete];
}

/// 获取 EOS 区块链的最新区块号
+ (void)__th_getInfo:(THEOSRequestCompleteBlock)complete {
    NSString *url = [NSString stringWithFormat:@"%@%@",[self __baseUrl],@"v1/chain/get_info"];
    [YCHttpTool getMethod:url parameter:nil result: complete];
}

/// push 交易
+ (void)__th_post_transaction:(NSDictionary *)dict complete:(THEOSRequestCompleteBlock)complete {
    NSString *url = [NSString stringWithFormat:@"%@%@",[self __baseUrl],@"v1/chain/push_transaction"];
    [YCHttpTool postMethod:url parameter:dict result:complete];
}

/// json 2 bin
+ (void)__th_json_to_bin:(NSDictionary *)dict complete:(THEOSRequestCompleteBlock)complete {
    NSString *url = [NSString stringWithFormat:@"%@%@",[self __baseUrl],@"v1/chain/abi_json_to_bin"];
    NSLog(@"json to bin: %@", dict);
    [YCHttpTool postMethod:url parameter:dict result:^(id content, id err) {
        NSLog(@"json to bin: %@, error: %@", content, err);
        if (err) {
            complete(nil,err);
        }
        else {
            if ([content isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary *)content;
                complete(dic[@"binargs"]?:@"",nil);
            }
        }
    }];
}
@end

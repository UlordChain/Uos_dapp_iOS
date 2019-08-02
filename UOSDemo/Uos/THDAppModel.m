//
//  THDAppModel.m
//  Ulrd
//
//  Created by tangwei on 2018/11/8.
//  Copyright © 2018 Tianhe Guoyun Technology Co., Ltd. All rights reserved.
//

#import "THDAppModel.h"
#import <MJExtension.h>

@implementation THDAppModel
+ (instancetype)modelFromJson:(id)dict {
    //    if (![dict isKindOfClass:[NSDictionary class]]) {
    //        NSString *msg = [NSString stringWithFormat:@"%@ 不是字典", dict];
    //        NSAssert(false, msg);
    //        return nil;
    //    }
    return [self.class mj_objectWithKeyValues: dict];
}

- (NSDictionary *)toJson {
    return [self mj_JSONObject];
}
@end

@implementation THDAppPushMessageModel
@end

@implementation THDAppScatterSignatureModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
        @"expiration" : @"transaction.expiration",
        @"ref_block_num" : @"transaction.ref_block_num",
        @"ref_block_prefix" : @"transaction.ref_block_prefix",
        @"chainId" : @"data.payload.network.chainId",
        @"actions" : @"transaction.actions",
        @"actor" : @"transaction.actions[0].authorization[0].actor",
        @"permission" : @"transaction.actions[0].authorization[0].permission",
        @"buffer" : @"buf.data",
    };
}

- (void)mj_keyValuesDidFinishConvertingToObject
{
    _chainId = @"aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906";
    
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    NSString *timeLocal = [NSString stringWithFormat:@"%@",localZone];
    timeLocal = [[timeLocal componentsSeparatedByString:@"(GMT"] lastObject];
    timeLocal = [[timeLocal componentsSeparatedByString:@") offset"] firstObject];
    NSInteger time = [timeLocal integerValue];
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    [dataFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *tmpDate = [dataFormatter dateFromString:_expiration];
    NSString *timeStr = [NSString stringWithFormat:@"%ld",(long)[tmpDate timeIntervalSince1970] + time * 3600];
    
    NSMutableDictionary *mdic = self.transaction.mutableCopy;
    mdic[@"expiration"] = timeStr;
    self.transaction = mdic.copy;
}
@end

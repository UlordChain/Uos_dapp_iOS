//
//  EosByteWriter.m
//  啊啊啊啊啊啊
//
//  Created by thgyuip on 2018/3/2.
//  Copyright © 2018年 thgyuip. All rights reserved.
//

#import "EosByteWriter.h"
#import "NSDate+ExFoundation.h"
#import "JKBigInteger.h"
#import "NSData+Hash.h"
#import "NSString+Base58.h"
#import "THEOSManager.h"

@interface EosByteWriter()
{
    NSMutableData *_buf;
    int _index;
}
@end

@implementation EosByteWriter

- (instancetype)initWithCapacity:(int) capacity {
    if (self = [super init]) {
        // 255
        _buf =  [NSMutableData dataWithLength:capacity];
//        _buf = [NSMutableData data];
        _index = 0;
    }
    return self;
}

- (void)ensureCapacity:(int)capacity {
    if (_buf.length - _index < capacity) {
        NSMutableData *temp = [NSMutableData dataWithLength:_buf.length*2+capacity];
        NSRange range = NSMakeRange(0, _buf.length);
        [temp replaceBytesInRange:range withBytes:[_buf bytes]];
        _buf = temp;
    }
}

- (void)put:(Byte)b {
    [self ensureCapacity:1];
    NSRange range = NSMakeRange(_index++, 1);
    Byte byte0[] = {b};
    [_buf replaceBytesInRange:range withBytes:byte0];
}

- (void)putShortLE:(short)value {
    [self ensureCapacity:2];
    NSRange range = NSMakeRange(_index++, 1);
    Byte byte0[] = {0xFF &(value)};
    [_buf replaceBytesInRange:range withBytes: byte0];
    range = NSMakeRange(_index++, 1);
    Byte byte1[] = {0xFF & (value >> 8)};
    [_buf replaceBytesInRange:range withBytes: byte1];
}

- (void)putIntLE:(int)value {
    [self ensureCapacity:4];
    NSRange range = NSMakeRange(_index++, 1);
    Byte byte0[] = {0xFF &(value)};
    [_buf replaceBytesInRange:range withBytes: byte0];
    
    range = NSMakeRange(_index++, 1);
    Byte byte1[] = {0xFF & (value >> 8)};
    [_buf replaceBytesInRange:range withBytes: byte1];
    
    range = NSMakeRange(_index++, 1);
    Byte byte2[] = {0xFF & (value >> 16)};
    [_buf replaceBytesInRange:range withBytes: byte2];
    
    range = NSMakeRange(_index++, 1);
    Byte byte3[] = {0xFF & (value >> 24)};
    [_buf replaceBytesInRange:range withBytes: byte3];
}

- (void)putUIntLE:(NSUInteger)value {
    [self ensureCapacity:4];
    NSRange range = NSMakeRange(_index++, 1);
    Byte byte0[] = {0xFF &(value)};
    [_buf replaceBytesInRange:range withBytes: byte0];
    
    range = NSMakeRange(_index++, 1);
    Byte byte1[] = {0xFF & (value >> 8)};
    [_buf replaceBytesInRange:range withBytes: byte1];
    
    range = NSMakeRange(_index++, 1);
    Byte byte2[] = {0xFF & (value >> 16)};
    [_buf replaceBytesInRange:range withBytes: byte2];
    
    range = NSMakeRange(_index++, 1);
    Byte byte3[] = {0xFF & (value >> 24)};
    [_buf replaceBytesInRange:range withBytes: byte3];
    
    range = NSMakeRange(_index++, 1);
    Byte byte4[] = {0xFF & (value >> 32)};
    [_buf replaceBytesInRange:range withBytes: byte4];
}


- (void)putLongLE:(long)value {
    [self ensureCapacity:8];
    NSRange range = NSMakeRange(_index++, 1);
    Byte byte0[] = {0xFF &(value)};
    [_buf replaceBytesInRange:range withBytes: byte0];
    
    range = NSMakeRange(_index++, 1);
    Byte byte1[] = {0xFF & (value >> 8)};
    [_buf replaceBytesInRange:range withBytes: byte1];
    
    range = NSMakeRange(_index++, 1);
    Byte byte2[] = {0xFF & (value >> 16)};
    [_buf replaceBytesInRange:range withBytes: byte2];
    
    range = NSMakeRange(_index++, 1);
    Byte byte3[] = {0xFF & (value >> 24)};
    [_buf replaceBytesInRange:range withBytes: byte3];
    
    range = NSMakeRange(_index++, 1);
    Byte byte4[] = {0xFF & (value >> 32)};
    [_buf replaceBytesInRange:range withBytes: byte4];
    
    range = NSMakeRange(_index++, 1);
    Byte byte5[] = {0xFF & (value >> 40)};
    [_buf replaceBytesInRange:range withBytes: byte5];
    
    range = NSMakeRange(_index++, 1);
    Byte byte6[] = {0xFF & (value >> 48)};
    [_buf replaceBytesInRange:range withBytes: byte6];
    
    range = NSMakeRange(_index++, 1);
    Byte byte7[] = {0xFF & (value >> 56)};
    [_buf replaceBytesInRange:range withBytes: byte7];
}

- (void)putBytes:(NSData *)value {
    [self ensureCapacity:(int)[value length]];
    NSRange range = NSMakeRange(_index, [value length]);
    [_buf replaceBytesInRange:range withBytes:[value bytes]];
    _index += [value length];
    
}

- (NSData *)toBytes {
    NSMutableData *data = [NSMutableData dataWithLength:_index];
    NSRange range = NSMakeRange(0, _index);
    [data replaceBytesInRange:range withBytes:[_buf bytes]];
//    [NSObject logoutByteWithNSData:_buf andLength:_index];
    return data;
}

- (int)length {
    return _index;
}

- (void)putString:(NSString *)value {
    if (nil == value) {
        [self putVariableUInt:0];
        return;
    }
    [self putVariableUInt:value.length];
    [self putBytes:[value dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)putCollection:(NSArray *)collection {
    if (nil == collection) {
        [self putVariableUInt:0];
        return;
    }
    [self putVariableUInt:[collection count]];
    for (int i = 0 ; i < collection.count; i++) {
        [self putLongLE:[NSObject string_to_long: collection[i]]];
    }
}


- (void)putVariableUInt:(long)val {
    do {
        Byte b = (Byte)((val) & 0x7f);
        val >>= 7;
        b |= ( ((val > 0) ? 1 : 0 ) << 7 );
        [self put:b];
    } while (val !=0 );
}

+ (NSData *)getBytesForSignature:(NSData *)chainId andParams:(NSDictionary *)paramsDic andCapacity:(int)capacity{
    
    EosByteWriter *writer = [[EosByteWriter alloc] initWithCapacity:capacity];
    
    if (chainId) {
        [writer putBytes:chainId];
    }
    [writer putIntLE: (int)[[paramsDic objectForKey:@"expiration"] integerValue]];
    
    long  max_net_usage_words=0, max_kcpu_usage=0, delay_sec =0; // uint16_t

    NSString *ref_block_num = [NSString stringWithFormat:@"%@", [paramsDic objectForKey:@"ref_block_num"]];
    [writer putShortLE: (short)([[[JKBigInteger alloc] initWithString: ref_block_num] intValue] & 0xFFFF) ];// uint16
    NSString *ref_block_prefix = [NSString stringWithFormat:@"%@", [paramsDic objectForKey:@"ref_block_prefix"]];

    [writer putIntLE:[[[JKBigInteger alloc] initWithString: ref_block_prefix] intValue] & 0xFFFFFFFF];// uint32
    [writer putVariableUInt:max_net_usage_words];
    [writer putVariableUInt:max_kcpu_usage];
    [writer putVariableUInt:delay_sec];

    // putCollection 系列,
    [writer putVariableUInt:0];

    // actions
    NSArray *actions = paramsDic[@"actions"];
    [writer putVariableUInt:actions.count];
    //[writer toBytes];

    for (NSInteger i=0; i<actions.count; i++) {

        NSMutableDictionary *actionDic = actions[i];
        [writer putLongLE:[NSObject string_to_long:actionDic[@"account"]]];
        [writer putLongLE:[NSObject string_to_long:actionDic[@"name"]]];

        // authorizationArray
        NSArray *authorizationArr = [actionDic objectForKey:@"authorization"];
        [writer putVariableUInt:authorizationArr.count];
        NSDictionary *authorizationDic = authorizationArr[0];
        [writer putLongLE:[NSObject string_to_long:authorizationDic[@"actor"]]];
        [writer putLongLE:[NSObject string_to_long:authorizationDic[@"permission"]]];

        NSString *data = [actionDic objectForKey:@"data"];
        if (NULL != data) {
            NSData *dataAsBytes = [NSObject convertHexStrToData:data];
            [writer putVariableUInt:dataAsBytes.length];// 数据长度
            [writer putBytes:dataAsBytes];
        }
        else {
            [writer putVariableUInt:0];
        }
    }

    for (int i = 0; i < 33; i++) {
        [writer putVariableUInt:0];
    }
    
    //[writer toBytes];

//    TypeChainId *chainId1 = [[TypeChainId alloc] init];
//    [writer putBytes:[chainId1 chainId]];
    //[writer toBytes];

    //NSData *snjj_data = [writer toBytes];
    return [writer toBytes];
}


+ (NSData *)getBytesForSignature2:(NSData *)chainId andParams:(NSDictionary *)paramsDic andCapacity:(int)capacity block:(void (^)(NSString *data))dataBlock{
    EosByteWriter *writer = [[EosByteWriter alloc] initWithCapacity:capacity];
    if (chainId) {
        [writer putBytes:chainId];
    }
    [writer putIntLE: (int)[[paramsDic objectForKey:@"expiration"] integerValue]];
    long  max_net_usage_words=0, max_kcpu_usage=0, delay_sec =0; // uint16_t
    
    [writer putShortLE: (short)([[[JKBigInteger alloc] initWithString:[paramsDic objectForKey:@"ref_block_num"] ] intValue] & 0xFFFF) ];// uint16
    [writer putIntLE:[[[JKBigInteger alloc] initWithString:[paramsDic objectForKey:@"ref_block_prefix"] ] intValue] & 0xFFFFFFFF];// uint32
    
    [writer putVariableUInt:max_net_usage_words];
    [writer putVariableUInt:max_kcpu_usage];
    [writer putVariableUInt:delay_sec];
    
    [writer putVariableUInt:0];
    
    NSArray *actions = paramsDic[@"actions"];
    [writer putVariableUInt:actions.count];
    
    for (NSInteger i=0; i<actions.count; i++) {
        
        NSMutableDictionary *actionDic = actions[i];
        [writer putLongLE:[NSObject string_to_long:actionDic[@"account"]]];
        [writer putLongLE:[NSObject string_to_long:actionDic[@"name"]]];
        
        NSArray *authorizationArr = [actionDic objectForKey:@"authorization"];
        [writer putVariableUInt:authorizationArr.count];
        NSDictionary *authorizationDic = authorizationArr[0];
        [writer putLongLE:[NSObject string_to_long:authorizationDic[@"actor"]]];
        [writer putLongLE:[NSObject string_to_long:authorizationDic[@"permission"]]];
    }
    NSString *data = [paramsDic objectForKey:@"data"];
    if (NULL != data) {
        NSData *dataAsBytes = [NSObject convertHexStrToData:data];
        [writer putVariableUInt:dataAsBytes.length];
        [writer putBytes:dataAsBytes];
    }else{
        [writer putVariableUInt:0];
    }
    [writer putVariableUInt:0];
    
    TypeChainId *chainId1 = [[TypeChainId alloc] init];
    [writer putBytes:[chainId1 chainId]];
        
    EosByteWriter *writer2 = [[EosByteWriter alloc] initWithCapacity:capacity];
    [self snjj:writer2 paramsDic:paramsDic];
    if (dataBlock) {
        NSData *data = [writer2 toBytes];
        NSString *snjjStr = [NSString hexWithData:data];
        dataBlock(paramsDic[@"data"]);
    }
    
    return [writer toBytes];
}


+ (void)snjj:(EosByteWriter *)writer paramsDic:(NSDictionary *)paramsDic{
    
    
    //正确
    [writer putLongLE:[NSObject string_to_long:paramsDic[@"from"]]];
    //正确
    [writer putLongLE:[NSObject string_to_long:paramsDic[@"to"]]];
    
    //1 4,EOS@eosio.token
    //16, 39, 0, 0, 0, 0, 0, 0, 4, 69, 79, 83, 0, 0, 0, 0
    
    NSString *stm = paramsDic[@"quantity"];
    CGFloat f_stm = [stm doubleValue];
    NSString *tmpStr = [NSString stringWithFormat:@"%.4f",f_stm];
    NSInteger e_num = [tmpStr doubleValue] * 10000;
    
    [writer putIntLE: (int)e_num];
    for (NSInteger i=0; i<4; i++) {
        [writer put:'\0'];
    }
    [writer put:'\4'];
    
    NSString *s = @"UOS";
    //@"EOS";
    [writer putBytes:[s dataUsingEncoding:NSUTF8StringEncoding]];
    for (NSInteger i=0; i<4; i++) {
        [writer put:'\0'];
    }
    
    //正确
    [writer putString:paramsDic[@"text"]];
    //NSLog(@"str = %@",snjjStr);
}

@end


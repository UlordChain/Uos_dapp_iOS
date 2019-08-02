//
//  EosByteWriter.h
//  啊啊啊啊啊啊
//
//  Created by thgyuip on 2018/3/2.
//  Copyright © 2018年 thgyuip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeChainId.h"
#import "NSObject+Extension.h"

@interface EosByteWriter : NSObject

- (instancetype)initWithCapacity:(int) capacity ;

- (void)ensureCapacity:(int)capacity ;

- (void)put:(Byte)b ;

- (void)putShortLE:(short)value ;

- (void)putIntLE:(int)value ;

- (void)putUIntLE:(NSUInteger)value;

- (void)putLongLE:(long)value ;

- (void)putBytes:(NSData *)value ;

- (NSData *)toBytes ;

- (int)length ;

- (void)putString:(NSString *)value ;

- (void)putCollection:(NSArray *)collection ;

- (void)putVariableUInt:(long)val ;

+ (NSData *)newAccountData:(NSDictionary *)data ;

+ (NSData *)getBytesForSignature:(NSData *)chainId andParams:(NSDictionary *)paramsDic andCapacity:(int)capacity;

+ (NSData *)getBytesForSignature2:(NSData *)chainId andParams:(NSDictionary *)paramsDic andCapacity:(int)capacity block:(void (^)(NSString *data))dataBlock;

+ (void)snjj:(EosByteWriter *)writer paramsDic:(NSDictionary *)paramsDic;

@end

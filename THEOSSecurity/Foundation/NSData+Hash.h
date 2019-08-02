//
//  NSData+Hash.h
//  啊啊啊啊啊啊
//
//  Created by thgyuip on 2018/3/5.
//  Copyright © 2018年 thgyuip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSData (Hash)
-(NSString *) sha256;

- (NSString *)hexadecimalString;

- (NSData *)SHA1;

- (NSData *)SHA256;

- (NSData *)SHA256_2;

- (NSData *)RMD160;

- (NSData *)hash160;

- (NSData *)reverse;

- (NSInteger)compare:(NSData *)data;

+ (NSData *)randomWithSize:(int)size;


@end

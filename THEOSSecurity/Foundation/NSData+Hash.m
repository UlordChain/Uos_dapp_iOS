//
//  NSData+Hash.m
//  啊啊啊啊啊啊
//
//  Created by thgyuip on 2018/3/5.
//  Copyright © 2018年 thgyuip. All rights reserved.
//

#import "NSData+Hash.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "SHAHash.h"

@implementation NSData (Hash)
-(NSString *) sha256{
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(self.bytes, (CC_LONG)self.length, digest);
    
    NSMutableString* outputSha256_Digest = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++){
        [outputSha256_Digest appendFormat:@"%02x", digest[i]];
    }
    return outputSha256_Digest;
}

- (NSString *)hexadecimalString{
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    
    if (!dataBuffer)
    {
        return [NSString string];
    }
    
    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
    {
        [hexString appendFormat:@"%02x", (unsigned int)dataBuffer[i]];
    }
    
    return [NSString stringWithString:hexString];
}

- (NSData *)SHA1 {
    return [SHAHash SHA1:self];
}

- (NSData *)SHA256 {
    return [SHAHash Sha2256:self];
}

- (NSData *)SHA256_2 {
    return [SHAHash Sha2256:[SHAHash Sha2256:self]];
}

- (NSData *)RMD160 {
    return [SHAHash RIPEMD160:self];
}

- (NSData *)hash160 {
    return self.SHA256.RMD160;
}

- (NSData *)reverse {
    NSUInteger l = self.length;
    NSMutableData *d = [NSMutableData dataWithLength:l];
    uint8_t *b1 = d.mutableBytes;
    const uint8_t *b2 = self.bytes;
    
    for (NSUInteger i = 0; i < l; i++) {
        b1[i] = b2[l - i - 1];
    }
    
    return d;
}

+ (NSData *)randomWithSize:(int)size; {
    OSStatus sanityCheck = noErr;
    uint8_t *bytes = NULL;
    bytes = malloc(size * sizeof(uint8_t));
    memset((void *) bytes, 0x0, size);
    sanityCheck = SecRandomCopyBytes(kSecRandomDefault, size, bytes);
    if (sanityCheck == noErr) {
        return [NSData dataWithBytes:bytes length:size];
    } else {
        return nil;
    }
}

@end

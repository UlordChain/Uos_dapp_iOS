//
//  SignYC.h
//  Oth
//
//  Created by th on 2018/6/13.
//  Copyright © 2018年 thgyuip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EosPrivateKey.h"

@interface THEOSSignManager : NSObject

+ (NSString *)signVC:(UIViewController *)vc ChainId:(NSString *)chainId privateKey:(NSString *)privateKey Ref_block_prefix:(NSString *)ref_block_prefix ref_block_num:(NSString *)ref_block_num expiration:(NSString *)expiration data:(NSString *)data twoData:(NSString *)twoData threeData:(NSString*)threeData eosTransfer:(BOOL)eosTransfer name:(NSString *)name to:(NSString *)to num:(NSString *)num text:(NSString *)text finish:(void(^)(id content,id error))finish;


+ (void)signWithVC:(UIViewController *)vc ChainId:(NSString *)chainId privateKey:(NSString *)privateKey body:(NSDictionary *)body finish:(void(^)(id content,id error))finish;

+ (NSString *)th_TansactionSignWithController:(UIViewController *)vc priKey:(NSString *)priKey chainId:(NSString *)chainId params:(NSDictionary *)params finish:(void(^)(id content,id error))finish;
@end

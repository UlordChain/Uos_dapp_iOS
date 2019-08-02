//
//  THEOSManager.h
//  Ulrd
//
//  Created by tangwei on 2018/8/27.
//  Copyright © 2018年 Tianhe Guoyun Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^THEOSRequestCompleteBlock)(id rslt, NSError *error);

@interface THEOSManager : NSObject
+ (void)th_scan_tranfer_data:(NSDictionary *)dict pk:(NSString *)pk complete:(THEOSRequestCompleteBlock)complete;
+ (void)th_scan_sign_data:(NSDictionary *)dict pk:(NSString *)pk complete:(THEOSRequestCompleteBlock)complete;
@end

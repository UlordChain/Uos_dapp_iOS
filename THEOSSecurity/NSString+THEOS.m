//
//  NSString+THEOS.m
//  Ulrd
//
//  Created by tangwei on 2018/9/1.
//  Copyright © 2018年 Tianhe Guoyun Technology Co., Ltd. All rights reserved.
//

#import "NSString+THEOS.h"

@implementation NSString (THEOS)
- (BOOL)th_isValidateEosAccount {
    NSString *reg = @"^[a-zA-Z1-5]{12}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",reg];
    if ([phoneTest evaluateWithObject:self]) {
        return true;
    }
    return false;
}
@end

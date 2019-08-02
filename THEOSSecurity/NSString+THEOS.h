//
//  NSString+THEOS.h
//  Ulrd
//
//  Created by tangwei on 2018/9/1.
//  Copyright © 2018年 Tianhe Guoyun Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (THEOS)
/// 是否是 标准的 eos 账号
- (BOOL)th_isValidateEosAccount;
@end

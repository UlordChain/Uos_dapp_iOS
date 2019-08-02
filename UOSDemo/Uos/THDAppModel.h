//
//  THDAppModel.h
//  Ulrd
//
//  Created by tangwei on 2018/11/8.
//  Copyright © 2018 Tianhe Guoyun Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THDAppModel : NSObject
+ (instancetype)modelFromJson:(id)dict;
- (NSDictionary *)toJson;
@end

@interface THDAppPushMessageModel : THDAppModel
@property (nonatomic, copy) NSString *methodName;
@property (nonatomic, copy) NSString *params;
@property (nonatomic, copy) NSString *serialNumber;
@end


@interface THDAppScatterSignatureModel : THDAppModel
/// 过期时间
@property (nonatomic, copy) NSString *expiration;
///
@property (nonatomic, copy) NSString *ref_block_num;
@property (nonatomic, copy) NSString *ref_block_prefix;
@property (nonatomic, copy) NSString *chainId;
@property (nonatomic, copy) NSString *actor;
/// 权限
@property (nonatomic, copy) NSString *permission;
@property (nonatomic, strong) NSArray *actions;
@property (nonatomic, strong) NSDictionary *transaction;


// 暂时没用到
@property (nonatomic, strong) NSArray *buffer;
@property (nonatomic, copy) NSString *scatterResult_id;
@property (nonatomic, copy) NSString *requestSignatureMessage;
@end

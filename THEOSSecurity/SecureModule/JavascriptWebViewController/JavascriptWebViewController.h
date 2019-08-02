//
//  JavascriptWebViewController.h
//  pocketEOS
//
//  Created by thgyuip on 2018/1/18.
//  Copyright © 2018年 thgyuip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JavascriptWebViewController : UIViewController

// 创建帐户签名
@property (nonatomic,copy)void (^finish)(NSString * sth);
- (void)sign:(NSString *)sth prikey:(NSString *)prikey;

@property(nonatomic,assign)BOOL  isDelegate;
// 根据私钥生成公钥
- (void)gain_pubkeyWithPrikey:(NSString *)prikey;

// 验证公钥格式
- (void)validePrikey:(NSString *)prikey;

@end

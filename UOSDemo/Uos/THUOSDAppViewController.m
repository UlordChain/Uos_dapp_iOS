//
//  THUOSDAppViewController.m
//  Ulrd
//
//  Created by tangwei on 2019/5/5.
//  Copyright © 2019 Tianhe Guoyun Technology Co., Ltd. All rights reserved.
//

#import "THUOSDAppViewController.h"
#import "THEOSManager.h"
#import "THDAppModel.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>
#import <Masonry.h>
#import <MJExtension.h>

/// 获取账户信息
#define kJSMethodNameGetUosAccount @"getUosAccount"
/// 跳转页面
#define kJSMethodNameTurnToTxPage @"turnToTxPage"
/// 签名
#define kJSMethodNameRequestSignature @"requestSignature"
/// 签名后push交易
#define kJSMethodNamePushActions @"pushActions"


#define kJSMethodNamePushMessage @"pushMessage"



#define kJSMethodNameCallbackResult @"callbackResult"

@interface THUOSDAppViewController ()
<
UIGestureRecognizerDelegate, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler
>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKUserContentController *userContentController;
@property (nonatomic, strong) WKProcessPool *sharedProcessPool;
@property (nonatomic, strong) UIProgressView *progressView;


@property (nonatomic, copy) NSString *messageName;
@property (nonatomic, strong) NSDictionary *messageBody;

@property (nonatomic, strong) THDAppPushMessageModel *pushModel;
@property (nonatomic, copy) NSString *uosPrivateKey;
@property (nonatomic, copy) NSString *uosPubkey;
@property (nonatomic, copy) NSString *uosAccount;
@end

@implementation THUOSDAppViewController

- (WKWebView *)webView
{
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        self.userContentController            = [[WKUserContentController alloc] init];
        configuration.userContentController   = self.userContentController;
        
        self.sharedProcessPool    = [[WKProcessPool alloc] init];
        configuration.processPool = self.sharedProcessPool;
        
        self.webView                    = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        self.webView.UIDelegate         = self;
        self.webView.navigationDelegate = self;
        
        if (@available(iOS 11.0, *)) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        self.webView.customUserAgent = @"UlordUosiOS";
        
        [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
        [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    5JCPmjsECKPxLaaLwvznEwyRVAYmo374HvS4AQqvmj97z86vbYP
//    UOS7rS4ZYqPU2unm63z4p6ZkP8XRxAEhZXTPHrfYeD4abE6vKetVX
//    jssdktester1
//
//
//    5JLnbgcxiUScFqpxk1VoSztdmhAx7H2xbRkUCxiZbDiAGYnn6A2
//    UOS5oZXMDvqKPU44ywjnLBXEHxJyKEjhyhDrLN2Rh77Z97KkNdZhz
//    jssdktester2
    self.uosAccount  = @"jssdktester1";
    self.uosPrivateKey = @"5JCPmjsECKPxLaaLwvznEwyRVAYmo374HvS4AQqvmj97z86vbYP";
    self.uosPubkey = @"UOS7rS4ZYqPU2unm63z4p6ZkP8XRxAEhZXTPHrfYeD4abE6vKetVX";
    
    [self __configureView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)__configureView {
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    NSURLRequest *finalRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://175.6.135.205:8011/demo/#/"]];
    [self.webView loadRequest:finalRequest];

    
    self.progressView                   = [UIProgressView new];
    self.progressView.progressTintColor = UIColor.blueColor;
    self.progressView.trackTintColor = UIColor.lightTextColor;
    [self.view addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.equalTo(self.view);
        make.height.mas_equalTo(2);
    }];
    
    [self __addController];
}


- (void)__addController {
    
    WKUserScript *u = self.userScript;
    if (u) {
        [self.userContentController addUserScript:u];
    }
    
    for (NSString *h in self.messageHandler) {
        [self.webView.configuration.userContentController addScriptMessageHandler:self name:h];
    }
    
    if (self.webView.title.length <= 0) {
        [self.webView reload];
    }
}

- (void)reloadContentView {
    [self __configureView];
}


- (void)injectUserData {
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    printf("\n");
    NSLog(@"js call name:%@\n body:%@\n frameInfo:%@\n", message.name, message.body, message.frameInfo.request.URL);
    printf("\n");
    _messageName = (NSString *) message.name;
    _messageBody = (NSDictionary *) message.body;
    if ([self.messageName isEqualToString:kJSMethodNamePushMessage]) {
        self.pushModel = [THDAppPushMessageModel modelFromJson:_messageBody];
        if ([self.pushModel.methodName isEqualToString:kJSMethodNameGetUosAccount]) {
            [self __getUosAccount];
        }
        else if ([self.pushModel.methodName isEqualToString:kJSMethodNameRequestSignature]) {
            [self __requestSignature];
        }
        else if ([self.pushModel.methodName isEqualToString:kJSMethodNamePushActions]) {
            [self __pushActions];
        }
    }
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    [webView reload];
}

- (void)__getUosAccount {
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    [resultDict setValue:self.uosPubkey forKey:@"publicKey"];
    [resultDict setValue:self.uosAccount forKey:@"name"];
    [resultDict setValue:@"uos" forKey:@"blockchain"];
    [resultDict setValue:@"owner" forKey:@"authority"];
    
    [self injectMethoName:kJSMethodNameCallbackResult serialNumber:self.pushModel.serialNumber msg:[resultDict mj_JSONString] completionHandler:nil];
}

- (void)__requestSignature {
    NSDictionary *dict = [self.pushModel.params mj_JSONObject];
    
    NSString *pk = self.uosPrivateKey;
    NSMutableDictionary *mDict = @{}.mutableCopy;
    NSString *authorization = ((NSArray *)dict[@"authorization"]).firstObject;
    NSString *actor = [authorization componentsSeparatedByString:@"@"].firstObject;
    NSString *permission = [authorization componentsSeparatedByString:@"@"].lastObject;
    NSDictionary *action = @{
                             @"account": dict[@"transfer_contract"],
                             @"name": dict[@"action"],
                             @"authorization": @[
                                     @{
                                         @"actor": actor,
                                         @"permission": permission
                                         }
                                     ],
                             @"data": dict[@"options"]
                             };
    mDict[@"actions"] = @[action];
    [THEOSManager th_scan_sign_data:mDict.copy pk:pk complete:^(id rslt, NSError *error) {
        if (rslt) {
            [self injectMethoName:kJSMethodNameCallbackResult serialNumber:self.pushModel.serialNumber msg:[[rslt mj_JSONString] stringByReplacingOccurrencesOfString:@"\\n" withString:@""] completionHandler:nil];
        }
        else {
            [self injectErrorMethoName:kJSMethodNameCallbackResult serialNumber:self.pushModel.serialNumber msg: @"error" completionHandler: nil];
        }
    }];
    
}

- (void)__pushActions {
    NSDictionary *dict = [self.pushModel.params mj_JSONObject];
    
    NSString *pk = self.uosPrivateKey;
    
    NSMutableDictionary *mDict = @{}.mutableCopy;
    NSString *authorization = ((NSArray *)dict[@"authorization"]).firstObject;
    NSString *actor = [authorization componentsSeparatedByString:@"@"].firstObject;
    NSString *permission = [authorization componentsSeparatedByString:@"@"].lastObject;
    NSDictionary *action = @{
                             @"account": dict[@"transfer_contract"],
                             @"name": dict[@"action"],
                             @"authorization": @[
                                     @{
                                         @"actor": actor,
                                         @"permission": permission
                                         }
                                     ],
                             @"data": dict[@"options"]
                             };
    mDict[@"actions"] = @[action];
    [THEOSManager th_scan_tranfer_data:mDict.copy pk:pk complete:^(id rslt, NSError *error) {
        if (rslt) {
            [self injectMethoName:kJSMethodNameCallbackResult serialNumber:self.pushModel.serialNumber msg:[[rslt mj_JSONString] stringByReplacingOccurrencesOfString:@"\\n" withString:@""] completionHandler:nil];
        }
        else {
            [self injectErrorMethoName:kJSMethodNameCallbackResult serialNumber:self.pushModel.serialNumber msg:@"error" completionHandler:nil];
        }
    }];
    
}


// 监听事件处理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context
{
    if ([keyPath isEqual:@"estimatedProgress"] && object == self.webView) {
        [self.progressView setAlpha:1.0f];
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        if (self.webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3
                                  delay:0.3
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self.progressView setAlpha:0.0f];
                             }
                             completion:^(BOOL finished) {
                                 [self.progressView setProgress:0.0f animated:YES];
                             }];
        }
    }
    else if ([keyPath isEqualToString:@"title"] && object == self.webView) {
        self.title = self.webView.title;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (WKUserScript *)userScript
{
    NSString *JSfilePath = [[NSBundle mainBundle] pathForResource:@"th_uos" ofType:@"js"];
    NSString *content    = [NSString stringWithContentsOfFile:JSfilePath encoding:NSUTF8StringEncoding error:nil];
    NSString * final     = [@"var script = document.createElement('script');"
                            "script.type = 'text/javascript';"
                            "script.text = \"" stringByAppendingString:content];
    return [[WKUserScript alloc] initWithSource:final injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
}

- (NSArray *)messageHandler
{
    return @[ kJSMethodNameGetUosAccount, kJSMethodNameTurnToTxPage, kJSMethodNameRequestSignature, kJSMethodNamePushActions ,kJSMethodNamePushMessage];
}

- (NSString *)userAgent {
    return @"UlordUosiOS";
}

- (void)injectErrorMethoName:(NSString *)name
                serialNumber:(NSString *)serialNumber
                         msg:(NSString *)msg
           completionHandler:(void (^_Nullable)(_Nullable id, NSError *_Nullable error))completionHandler
{
    NSString *jsStr = [NSString stringWithFormat:@"%@('%@', '%@', '%@')", name, serialNumber, nil, msg];
    [self injectData:jsStr completionHandler:completionHandler];
}

- (void)injectMethoName:(NSString *)name
           serialNumber:(NSString *)serialNumber
                    msg:(NSString *)msg
      completionHandler:(void (^_Nullable)(_Nullable id, NSError *_Nullable error))completionHandler
{
    NSString *jsStr = [NSString stringWithFormat:@"%@('%@', '%@')", name, serialNumber, msg];
    [self injectData:jsStr completionHandler:completionHandler];
}

- (void)injectData:(NSString *)bodyString completionHandler:(void (^)(id _Nullable, NSError *_Nullable))completionHandler
{
    printf("\n");
    NSLog(@"【native to js】 : %@", bodyString);
    printf("\n");
    [self.webView evaluateJavaScript:bodyString
                   completionHandler:^(id _Nullable rsp, NSError *_Nullable error) {
                       if (rsp || error) {
                           printf("\n");
                           NSLog(@"【native to js response 】:%@ error: %@", rsp, error);
                           printf("\n");
                       }
                       completionHandler ? completionHandler(rsp, error) : nil;
                   }];
}

@end

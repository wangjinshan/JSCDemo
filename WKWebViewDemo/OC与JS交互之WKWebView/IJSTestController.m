

//
//  IJSTestController.m
//  OC与JS交互之WKWebView
//
//  Created by 山神 on 2018/6/13.
//  Copyright © 2018年 rrcc. All rights reserved.
//

#import "IJSTestController.h"
#import <WebKit/WebKit.h>
#import "IJSTestObjc.h"
#import "TouchController.h"

@interface IJSTestController () <WKUIDelegate,WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet UIView *backView;

@property(nonatomic,strong) WKWebView *wkwebV;  // 参数说明
@property(nonatomic,strong) IJSTestObjc *objc;  // 参数说明
@property (weak, nonatomic) IBOutlet UIProgressView *wkProgressV;
@property(nonatomic,strong) TouchController *touchVc;  // 参数说明

@end

@implementation IJSTestController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor greenColor];
    [self _setupWK];
}
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.wkwebV.frame = CGRectMake(0, 0, self.backView.frame.size.width, self.backView.frame.size.height);
}

- (void)_setupWK
{
    self.objc =[IJSTestObjc new];
    // 进程池配置
    WKWebViewConfiguration  * config = [[WKWebViewConfiguration alloc]init];
    config.applicationNameForUserAgent = @"applicationNameForUserAgent应用名称";
    config.ignoresViewportScaleLimits =YES; // 允许页面缩放
    config.suppressesIncrementalRendering = NO; // 是否抑制内容渲染呈现，直到它完全载入内存
    config.allowsInlineMediaPlayback = NO; // 不使用系统的播放器
    config.allowsAirPlayForMediaPlayback =YES; //是否允许AirPlay播放媒体
    config.allowsPictureInPictureMediaPlayback =YES; // 是否允许HTML5视屏以画中画形式播放,iPhone不支持
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeVideo; //哪些媒体类型需要用户手势才能开始播放

    config.selectionGranularity = WKSelectionGranularityDynamic; //用户可以在WebView中交互式地选择内容的粒度级别,比如说，当使用WKSelectionGranularityDynamic时，而所选择的内容是单个块，这时候granularity可能会是单个字符；当所选择的web内容不限制于某个块时，granularity可能会是单个块。
    config.dataDetectorTypes = WKDataDetectorTypeLink;
    /*
     WKDataDetectorTypeNone //不执行检测
     WKDataDetectorTypePhoneNumber // 电话号码
     WKDataDetectorTypeLink //文本中的url
     WKDataDetectorTypeAddress // 地址
     WKDataDetectorTypeCalendarEvent //在未来的日期和时间
     WKDataDetectorTypeTrackingNumber // 跟踪号码/查询号/运单号
     WKDataDetectorTypeFlightNumber // 航班号
     WKDataDetectorTypeLookupSuggestion
     WKDataDetectorTypeAll = NSUIntegerMax, //所有
     */
    // 暂时不知道干啥用的
    [config setURLSchemeHandler:self.objc forURLScheme:@"weixin"];
    id urlscheme =  [config urlSchemeHandlerForURLScheme:@"weixin"];

    WKPreferences *preferences = [[WKPreferences alloc]init];
    preferences.minimumFontSize = 10; //最小字体的尺寸
    preferences.javaScriptEnabled =YES; //是否启用JavaScript,设置为NO将会禁用页面加载的或执行的JavaScript,但这个配置不会影响用户的script
    preferences.javaScriptCanOpenWindowsAutomatically =YES;//是否可以在没有用户操作的情况下自动打开窗口
    config.preferences = preferences;
    
    
    WKProcessPool *processPool = [[WKProcessPool alloc]init];
    config.processPool =processPool;
    
    WKUserContentController *userContentController =[[WKUserContentController alloc]init];
    config.userContentController = userContentController;
    
    WKWebsiteDataStore *websiteDataStore = [WKWebsiteDataStore nonPersistentDataStore]; //无痕浏览
    config.websiteDataStore = websiteDataStore;
    
    // 属性设置
    self.wkwebV =[[WKWebView alloc]initWithFrame:CGRectZero configuration:config];
    [self.backView insertSubview:self.wkwebV atIndex:0];
    self.wkwebV.allowsBackForwardNavigationGestures = YES; // 全屏滑动
    self.wkwebV.allowsLinkPreview = YES; //按住预览
    
    self.wkwebV.navigationDelegate = self;
    self.wkwebV.UIDelegate = self;

    // ios11添加规则
    WKContentRuleListStore *rulerListStrore =[WKContentRuleListStore defaultStore];
    
    
    NSString *javaScriptSource = @"function userFunc(){window.confirm('sometext');}";    //@"function userFunc(){ alert('警告')}";
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:javaScriptSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    // forMainFrameOnly:NO(全局窗口)，yes（只限主窗口）
    [config.userContentController addUserScript:userScript];
  
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *baseURL = [[NSBundle mainBundle] bundleURL];
//    [self.wkwebV loadHTMLString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] baseURL:baseURL];

    [self.wkwebV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://v.qq.com/x/cover/7casb7nes159mrl.html?ptag=baidu.video.paymovie&frp=v.baidu.com%2Fmovie_intro%2F&vfm=bdvtx"]]];
   
    [self.wkwebV.configuration.userContentController addScriptMessageHandler:self.objc name:@"showName"];
    [config.userContentController addScriptMessageHandler:self.objc name:@"userFunc"];
    
    [self.wkwebV addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [self.wkwebV.configuration.userContentController removeAllUserScripts];
    //        [self dismissViewControllerAnimated:YES completion:nil];
    //    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        WKSnapshotConfiguration *snap =[[WKSnapshotConfiguration alloc]init];
//        snap.rect = CGRectMake(100, 100, 100, 100);
//        snap.snapshotWidth = @(100);
//        [self.wkwebV takeSnapshotWithConfiguration:snap completionHandler:^(UIImage * _Nullable snapshotImage, NSError * _Nullable error) {
//            UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(50, 50, 300, 300)];
//            imageV.image = snapshotImage;
//            [self.wkwebV addSubview:imageV];
//        }];
//    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.wkwebV evaluateJavaScript:@"userFunc()" completionHandler:^(id _Nullable resp, NSError * _Nullable error) {

        }];
        NSURL *url = [NSURL URLWithString:@"wjs://"];
        //打开url
        [[UIApplication sharedApplication] openURL:url];
    });
    [userContentController.userScripts enumerateObjectsUsingBlock:^(WKUserScript * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"-------1----%@",obj.source);
    }];
//    WKContentRuleListStore
//    WKWebsiteDataStore
//    WKContentRuleList
//    WKWebsiteDataRecord
//    WKSelectionGranularity
//WKURLSchemeTask
//WKURLSchemeHandler
    WKBackForwardList
}
#pragma mark -  WKNavigationDelegate
//
//- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
//{
//    NSLog(@"当WebView开始接收网页内容时触发");
//}
//- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
//{
//    NSLog(@"当WevView的内容开始加载时触发");
//}
//
//- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
//{
//    NSLog(@"主机地址重定向时触发");
//}
//
//- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
//{
//    NSLog(@"当页面加载内容过程中发生错误时触发");
//}
//
//- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
//{
//    NSLog(@"当前页面加载完成后触发");
//}
//
//- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
//{
//    NSLog(@"页面发生错误时触发");
//}
//
//- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
//{
//    NSLog(@"当WebView需要响应网页的登录请求时触发");
//    completionHandler(NSURLSessionAuthChallengeUseCredential,nil);
//}
//
//- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
//{
//    NSLog(@"当WebContent进程中止时触发");
//}

//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
//{  // WKNavigationActionPolicyCancel 取消请求          WKNavigationActionPolicyAllow 允许继续
//    NSLog(@"决定是否允许或者取消一次页面加载请求");
//    NSLog(@"----%@",navigationAction);
//    decisionHandler(WKNavigationActionPolicyAllow);
//}
//
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
//{   // WKNavigationResponsePolicyCancel 取消加载       WKNavigationResponsePolicyAllow 允许继续
//    NSLog(@"在已经收到response时决定是否允许或者取消页面的加载");
//    decisionHandler(WKNavigationResponsePolicyAllow);
//}

#pragma mark -  WKUIDelegate
// 这个方法相当于浏览器中的新建窗口,这个方法触发的条件是当html中点击了 A 标签需要新开窗口时候
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{ // 这个处理方法解决的是,当某些界面点击 A 标签无响应的问题,就是存在 target='_blank' 时
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame])
    {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
- (void)webViewDidClose:(WKWebView *)webView
{
 // webview 关闭
}
// 显示一个JavScript 警告界面
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{  // 对应着 alert('警告')
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    // alert弹出框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
// 带着确认取消的弹框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{  // window.confirm('sometext');
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    // alert弹出框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:ok];
    [alertController addAction:no];
    [self presentViewController:alertController animated:YES completion:nil];
}
// 带着输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入框" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor blackColor];
        textField.placeholder = defaultText;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(nil);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}
//  决定是否要预览指定的WKPreviewElementInfo
- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo
{
    return YES;
}
// 当用户发出了预览操作（比如3D Touch按压）时调用
- (nullable UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions
{
     self.touchVc =[[TouchController alloc]init];
    WKWebView *wk = [[WKWebView alloc]initWithFrame:CGRectMake(50, 100, 300, 300) configuration:webView.configuration];
    [wk loadRequest:[NSURLRequest requestWithURL:elementInfo.linkURL]];
    UILabel *label =[[UILabel alloc]initWithFrame:CGRectMake(20, 30, 100, 100)];
    label.text = previewActions.firstObject.title;
    [wk addSubview:label];
    self.touchVc.itemArr = previewActions;
    [self.touchVc.view addSubview:wk];
    return self.touchVc;
}
/// 继续按压
- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController
{
    [self addChildViewController:self.touchVc];
}

// 长按图片保存
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{// 不执行前段界面弹出列表的JS代码
    [self.wkwebV evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
}
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    CGPoint touchPoint = [sender locationInView:self.wkwebV];
    // 获取长按位置对应的图片url的JS代码
    NSString *imgJS = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    // 执行对应的JS代码 获取url
    [self.wkwebV evaluateJavaScript:imgJS completionHandler:^(id _Nullable imgUrl, NSError * _Nullable error) {
        if (imgUrl)
        {
        }
    }];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"])
    {
        self.wkProgressV.progress = self.wkwebV.estimatedProgress;
//        [self _logWKInfo];
//        NSLog(@"--c------%@",self.wkwebV.backForwardList.currentItem.title);
//        NSLog(@"---b-----%@",self.wkwebV.backForwardList.backItem.title);
//        NSLog(@"---f-----%@",self.wkwebV.backForwardList.forwardItem.title);
    }
}

- (IBAction)backAction:(UIButton *)sender
{
    [self.wkwebV goBack];
}
- (IBAction)goForAction:(UIButton *)sender
{
    [self.wkwebV goForward];
}

- (IBAction)wuhenAction:(UIButton *)sender
{

}

- (IBAction)stopLoadingAction:(UIButton *)sender
{
    [self.wkwebV stopLoading];
}
// 刷新返回的是上一个界面
- (IBAction)reloadAction:(UIButton *)sender
{
    [self.wkwebV reload];
}

- (IBAction)listAction:(UIButton *)sender
{

}
// 重加载
- (IBAction)test1Action:(UIButton *)sender
{
    [self.wkwebV reloadFromOrigin];
}

- (IBAction)test2Action:(UIButton *)sender
{

}

-(void)_logWKInfo
{
    NSMutableDictionary *dic =[NSMutableDictionary dictionary];
    [dic setValue:self.wkwebV.customUserAgent forKey:@"customUserAgent"];
    [dic setValue:@(self.wkwebV.canGoBack) forKey:@"canGoBack"];
    [dic setObject:@(self.wkwebV.canGoForward) forKey:@"canGoForward"];
//    [dic setObject:self.wkwebV.serverTrust forKey:@"serverTrust"];
    [dic setObject:@(self.wkwebV.hasOnlySecureContent) forKey:@"hasOnlySecureContent"];
    [dic setObject:@(self.wkwebV.loading) forKey:@"loading"];
    [dic setObject:self.wkwebV.title forKey:@"title"];
    [dic setObject:self.wkwebV.URL forKey:@"url"];
    [dic setObject:self.wkwebV.backForwardList forKey:@"backForwardList"];
    NSLog(@"--------------------------start--------------------------");
    NSLog(@"%@",dic);
    NSLog(@"--------------------------stop--------------------------");
}



-(void)dealloc
{
    NSLog(@"----------IJSTestController---------------");
//    [self.wkProgressV removeObserver:self forKeyPath:@"estimatedProgress"];
}




@end

# WebKit 认知

之前学习交互,把WK落下了,现在补上.
WK中有些类,在目前的项目中没有用到,可能存在问题,本文也没加注释,后面会补上,这个文章属于WebKit的入门文档,如果有小伙伴只想知道怎么交互,前面的基础知识可以直接忽略,如果觉得文章中有错误还望指出 **QQ: 1096452045**

### 一,核心类  WKWebView

#### 1,属性:

```
1.  WKWebViewConfiguration *configuration;//配置属性,下文会提及 
2.  id <WKNavigationDelegate> navigationDelegate;//可以自定义WebView接受、加载和完成浏览请求过程的一些行为
3.  id <WKUIDelegate> UIDelegate;  // 界面代理
4.  WKBackForwardList *backForwardList;// 维护了用户访问过的网页记录.下文细讲
5.  NSString *title;//当前页面的title 
6.  NSURL *URL; //当前的URL
7.  BOOL loading; //属性来判断网页是否正在加载中
8.  double estimatedProgress;//当前浏览页面加载进度的比例 0--1 支持kvo
9.  BOOL hasOnlySecureContent;//是否页面内的所有资源都是通过安全链接加载的
1. SecTrustRef serverTrust //10.0+当前浏览页面的SecTrustRef对象,此对象暂时没有细究
2.  BOOL canGoBack; //是否可以后退。
3.  BOOL canGoForward; // 是否可以向前
4.  BOOL allowsBackForwardNavigationGestures;//是否允许水平滑动手势来触发网页的前进和后退,相当于全屏返回
5.  NSString *customUserAgent // 9.0+自定义User Agent 
6.  BOOL allowsLinkPreview// 是否允许按住链接就展示链接的预览 3DTouch支持 
7.  UIScrollView *scrollView; //WebView对应的ScrollView
8.  BOOL allowsMagnification;//mac 是否允许放大手势来放大网页内容
9.  CGFloat magnification; //mac 影响网页内容放缩的因子 默认是1

```
#### 2,方法列表:

* [ ] 初始化

```
使用 initWithFrame:configuration: 方法来创建WKWebView对象；
```

* [ ]  加载资源
* 本地
 
```
 NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *baseURL = [[NSBundle mainBundle] bundleURL];
    [self.wkwebV loadHTMLString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] baseURL:baseURL];

NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
NSURL *baseURL = [[NSBundle mainBundle] bundleURL];
[self.wkwebV loadHTMLString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] baseURL:baseURL];
```
* 网络

```
 [self.wkwebV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://v.qq.com/x/cover/7casb7nes159mrl.html?ptag=baidu.video.paymovie&frp=v.baidu.com%2Fmovie_intro%2F&vfm=bdvtx"]]];  
 
- (WKNavigation *)loadData:(NSData *)data MIMEType:(NSString *)MIMEType characterEncodingName:(NSString *)characterEncodingName baseURL:(NSURL *)baseURL;
### MIMEType是数据类型 characterEncodingName是编码名称baseURL是用于解析文档内相对URL的URL,返回一个新的WKNavigation对象  
```
* [ ]  决定是否加载内容 返回WebKit是否原生地支持某一种URL Scheme ios11

```
+ (BOOL)handlesURLScheme:(NSString *)urlScheme;
```
* [ ] 操作界面API

```
- (nullable WKNavigation *)goBack; //返回

- (nullable WKNavigation *)goForward; //前进

- (nullable WKNavigation *)reload; //重加载,刷新发现是返回上一个界面

- (nullable WKNavigation *)reloadFromOrigin; //重新加载当前页面(带缓存的验证),应该用此刷新

- (void)stopLoading;// 停止加载

```
###### 缩放属性和方法在iphone 没有实践

#### 3,加载JavaScript

```
[wkwebview evaluateJavaScript:js方法 completionHandler:^(id _Nullable resp, NSError * _Nullable error) {
resp 是 js返回的值, 主线程中执行
            }];
```
#### 4, ios11 网页截屏

``` 
WKSnapshotConfiguration *snap =[[WKSnapshotConfiguration alloc]init];
        snap.rect = CGRectMake(100, 100, 100, 100);//截取限制
        snap.snapshotWidth = @(100); //控制截屏像素
        [self.wkwebV takeSnapshotWithConfiguration:snap completionHandler:^(UIImage * _Nullable snapshotImage, NSError * _Nullable error) {
            //这个方法必须在网页加载完成之后执行,否则返回的就是一个空白的image
        }];
```
#### 5, 代理
##### 5.1,WKNavigationDelegate

```
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"当WebView开始接收网页内容时触发");
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"当WevView的内容开始加载时触发");
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"主机地址重定向时触发");
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"当页面加载内容过程中发生错误时触发");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"当前页面加载完成后触发");
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"页面发生错误时触发");
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    NSLog(@"当WebView需要响应网页的登录请求时触发");
    completionHandler(NSURLSessionAuthChallengeUseCredential,nil);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    NSLog(@"当WebContent进程中止时触发");
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{  // WKNavigationActionPolicyCancel 取消请求          WKNavigationActionPolicyAllow 允许继续
    NSLog(@"决定是否允许或者取消一次页面加载请求");
    NSLog(@"----%@",navigationAction);
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{   // WKNavigationResponsePolicyCancel 取消加载       WKNavigationResponsePolicyAllow 允许继续
    NSLog(@"在已经收到response时决定是否允许或者取消页面的加载");
    decisionHandler(WKNavigationResponsePolicyAllow);
}
```
##### 5.1.1 WKNavigationAction
此对象包含了可能导致一次加载的操作的信息，用于制定策略决策
###### 属性

```
WKFrameInfo *sourceFrame;//产生这次请求的frame信息
NSURLRequest *request; // 加载的请求信息

WKFrameInfo *targetFrame;//请求的目标frame，如果时一个新的窗口请求则是nil

WKNavigationType navigationType; 触发本次浏览请求的操作类型。见WKNavigationType枚举

```
**WKNavigationType 枚举**

```
WKNavigationTypeLinkActivated 带有href属性的链接被用户激活

WKNavigationTypeFormSubmitted 一个表单提交

WKNavigationTypeBackForward 向前向后的导航请求

WKNavigationTypeReload 网页重新加载

WKNavigationTypeFormResubmitted 重新提交表单(例如后退、前进或重新加载)

WKNavigationTypeOther由于其他原因
```
**WKNavigationResponse** 
对象包含用于制定策略决策的浏览响应信息
###### 属性:

```
BOOL forMainFrame; //指示本次加载的frame是否是main frame

NSURLResponse *response; // 如果允许了一个带有无法显示的MIME类型响应，会导致浏览加载失败

BOOL canShowMIMEType; // 指示WebKit是否可以原生地支持显示这种MIME类型 
```
##### 5.2 WKUIDelegate
5.2.1 创建新窗口

```
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
```
5.2.2 关闭

```
- (void)webViewDidClose:(WKWebView *)webView
{
 // webview 关闭
}
```
5.2.3 网页中带着警告

```
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
```
5.3.4 3DTouch相关,按压出现列表

```
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
    label.text = previewActions.firstObject.identifier;
    [wk addSubview:label];
    [self.touchVc.view addSubview:wk];
    return self.touchVc;
}
/// 继续按压
- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController
{
    [self addChildViewController:self.touchVc];
}
```
联想: 这三个代理需要联合使用,和3DTouch案例是一样的
联想: 网页长按图片保存功能的实现

```
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
```
5.3.5 回调中的类 

**WKWindowFeatures** 新打开的窗口的可选属性
 
属性列表

```
NSNumber *allowsResizing;// 窗口是否可以调整尺寸（Boolean）
NSNumber *height;//窗口的高度（CGFloat）
NSNumber *width;//窗口的宽度（CGFloat）
NSNumber *x; //窗口的x坐标（CGFloat）
NSNumber *y;//窗口的y坐标（CGFloat）
NSNumber *menuBarVisibility;//菜单栏是否应该可见（Boolean）
NSNumber *statusBarVisibility;//状态栏是否应该可见（Boolean）
NSNumber *toolbarsVisibility;//工具栏是否应该可见（Boolean）
```
**WKPreviewElementInfo** 对象包含了预览网页的信息

属性列表

```
NSURL *linkURL; //预览网页的链接
```
**WKPreviewActionItem** 协议提供预览操作的一些属性的访问方法。继承自UIPreviewActionItem
属性列表

```
NSString *identifier; //预览操作的标志符
```
**UIPreviewActionItem** 返回的就是3dTouch中的选项列表

```
NSString *title; 此字段就是touch列表中的标题
```
### 二 配置信息类
#### 1,WKWebViewConfiguration
此类:
可以决定网页的渲染时机，媒体的播放方式，用户选择项目的粒度，以及很多其他的选项.
WKWebViewConfiguration只会在webview第一次初始化的时候使用，你不能用此类来改变一个已经初始化完成的webview的配置。

```
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
```
#### 2,WKPreferences
此类封装了一个webview的偏好选项
属性:

```
preferences.minimumFontSize = 10; //最小字体的尺寸
preferences.javaScriptEnabled =YES; //是否启用JavaScript,设置为NO将会禁用页面加载的或执行的JavaScript,但这个配置不会影响用户的script   
preferences.javaScriptCanOpenWindowsAutomatically =YES;//是否可以在没有用户操作的情况下自动打开窗口
```
#### 3,WKProcessPool

一个WKProcessPool对象代表Web Content的进程池。
与WebView的进程池关联的进程池通过其configuration来配置。每个WebView都有自己的Web Content进程，最终由一个有具体实现的进程来限制;在此之后，具有相同进程池的WebView最终共享Web Content进程.
WKProcessPool对象只是一个简单的不透明token，本身没有属性或者方法
#### 4,WKUserContentController
提供了一种向WebView发送JavaScript消息或者注入JavaScript脚本的方法

* 属性:

```
NSArray<WKUserScript *> *userScripts //用户手动添加的js代码
```
* 方法列表
* [ ] 添加和删除脚本

```
- (void)addUserScript:(WKUserScript *)userScript; //添加用户自己的js代码
```

```
- (void)removeAllUserScripts;//移除所有的WKUserScript
```
* [ ] 注册js的方法列表

```
- (void)addScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name;
// 注册js的方法列表,此处的第一个参数不能是控制器self.否则内存问题
这里的名字就是 js中, name的关键字 window.webkit.messageHandlers.name.postMessage(messageBody)
postMessage()有两个参数,第一个参数是需要传递的参数,第二个参数可以理解为标识,这俩参数可传可不传, 参数可以是js中的任何对象
```

```
- (void)removeScriptMessageHandlerForName:(NSString *)name;// 移除name名字的WKScriptMessageHandler
```
* 添加或移除Content Rules

```
- (void)addContentRuleList:(WKContentRuleList *)contentRuleList;
- (void)removeContentRuleList:(WKContentRuleList *)contentRuleList;
- (void)removeAllContentRuleLists;
```
#### 5,WKScriptMessageHandler 处理js回调的协议,后面将交互的时候回提及
#### 6,WKScriptMessage 这个是js回调过来的消息实体
属性:

```
 id body;//只能是这些类型 NSNumber, NSString, NSDate, NSArray, NSDictionary, NSNull
 WKFrameInfo *frameInfo;//发送消息的frame
 NSString *name;//发送消息的WKScriptMessageHandler的名字 就是js方法名字
  WKWebView *webView;// 发送消息的WKWebView
```
#### 7,WKFrameInfo
包含了一个网页中的farme的相关信息。其只是一个描述瞬时状态的纯数据对象，不能用来在多次消息调用中唯一标识一个frame
属性:

```
BOOL mainFrame;//该frame是否是该网页的main frame或者子frame
NSURLRequest *request;//frame对应的当前的请求
WKSecurityOrigin *securityOrigin;//frame的securityOrigin
WKWebView *webView;//frame对应的webView
```
#### 8,WKSecurityOrigin
一个WKSecurityOrigin对象由host，protocol和port组成。任何一个与正在加载的网页拥有相同WKSecurityOrigin的URL加载是一个First Party加载。First Party网页可以访问彼此的脚本和数据库资源。其只是一个描述瞬时状态的纯数据对象，不能用来在多次消息调用中唯一标识一个SecurityOrigin
属性:

```
 NSString *host;
 NSInteger port;
 NSString *protocol;
```
#### 9,WKUserScript
代表了一个可以被注入网页中的脚本
例如

```
NSString *javaScriptSource = @"function userFunc(){window.confirm('sometext');}";    //@"function userFunc(){ alert('警告')}";
WKUserScript *userScript = [[WKUserScript alloc] initWithSource:javaScriptSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
// forMainFrameOnly:NO(全局窗口)，yes（只限主窗口）
[config.userContentController addUserScript:userScript];
* source 脚本的代码
* injectionTime 脚本注入的时机，必须是这个WKUserScriptInjectionTime枚举值
* forMainFrameOnly YES 只向main frame注入脚本， NO 则会向所有的frame注入脚本
```
属性:

```
NSString *source; //脚本的代码
WKUserScriptInjectionTime injectionTime;//脚本注入的时机
BOOL forMainFrameOnly;//是否只注入到main frame
```
枚举:

```
typedef NS_ENUM(NSInteger, WKUserScriptInjectionTime) {
    WKUserScriptInjectionTimeAtDocumentStart,//在document element创建之后，在所有其他内容加载之前
    WKUserScriptInjectionTimeAtDocumentEnd //在document加载完成之后，在其他子资源加载完成之前
}
```
#### 10, WKContentRuleList
一个编译过的规则列表，应用到Web Content上。从WKContentExtensionStore中创建或者取得。//位置
属性

```
 NSString *identifier;//标识符
```
#### 11,WKContentRuleListStore
方法列表

```
+ (instancetype)defaultStore;// 返回默认的Store
```
#### 12,WKWebsiteDataStore
一个WKWebsiteDataStore对象代表了被网页使用的各种类型的数据。包括cookies，磁盘文件，内存缓存以及持久化数据如WebSQL，IndexedDB数据库，local storage
#### 13, WKHTTPCookieStore
管理与特定的WKWebsiteDataStore关联的HTTP cookie的对象
#### 14, WKHTTPCookieStoreObserver
    
#### 15,WKWebsiteDataRecord    

#### 16,WKURLSchemeHandler
用来处理WebKit无法处理的URL Scheme类型的资源
方法:

```
//开始加载特定资源时调用
- (void)webView:(WKWebView *)webView startURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask;
//handler停止处理这个任务时调用这个方法,在此此方法调用之后，你的handler不应该调用这个任务的任何方法，否则会触发异常
- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask;
```
#### 17,WKURLSchemeTask
用来加载资源的任务
属性:

```
NSURLRequest *request; //加载的请求
```
方法:

```
- (void)didReceiveResponse:(NSURLResponse *)response;
每个任务必须至少调用一次这个方法
如果你尝试在任务完成后发送一个新的response对象，会触发异常
如果在任务已经停止加载后调用，将会触发异常
```
```
- (void)didReceiveData:(NSData *)data;
在任务接受到最终的response对象后，你应当开始发送数据
每次调用这个方法，新的数据都会append到之前的数据后
如果你尝试在发送response之前或者任务已经结束之后发送数据，将会触发异常
如果在任务已经停止加载后调用，将会触发异常
```

```
- (void)didFinish;
如果你尝试在发送response之前或者任务已经结束之后调用该方法，将会触发异常
如果在任务已经停止加载后调用，将会触发异常
```

```
- (void)didFailWithError:(NSError *)error;
如果在任务已经被标记为结束或失败后再调用这个方法会触发异常
如果在任务已经停止加载后调用，将会触发异常
```
#### 18,WKBackForwardList
一个WKBackForwardList对象维护了用户访问过的网页记录，用来前进后退到最近加载过的网页。WKBackForwardList对象仅仅维护的是列表数据，并不会执行任何实际的网页加载的操作，不会产生任何客户请求。如果你需要产生一次页面加载，请使用loadRequest: 这些方法
属性:

```
WKBackForwardListItem *backItem; //上一个
WKBackForwardListItem *currentItem; //当前
WKBackForwardListItem *forwardItem; //下一个记录 
NSArray<WKBackForwardListItem *> *backList;//后退访问记录
NSArray<WKBackForwardListItem *> *forwardList;//向前
```
方法:

```
 //坐标位置的item
- (nullable WKBackForwardListItem *)itemAtIndex:(NSInteger)index;
```
#### 19,WKBackForwardListItem
WKBackForwardListItem对象代表了前进后退记录中的一个网页，包含了网页的一些信息（URL，标题和创建网页时的URL），前进后退记录由WKBackForwardList维护
属性:

```
NSURL *URL; //网页的URL
NSURL *initialURL; //创建记录时初始化传入的URL
NSString *title; // 网页的标题
```
<hr>

### 三, 基于WKWebView的ios与js交互细节

如果之前看过我写的基于 UIWebview和 JavaScriptCore ios与js的交互的话下面的内容将非常好理解

#### 1, ios调用js代码
ios调用js代码其实非常简单,只有一句代码

```
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;
第一个参数是你需要执行的js方法,参数义字符的形式拼接进去,这里面的数据转换类型和之前文档中的数据转换类型一样,请参考之前的例子
```
实战如下:
调用js中的代码:

```
js中的代码:
function alertSendMsg(num,msg)
{
    var objc = new num(); 
    document.getElementById('msg').innerHTML = '这是我的手机号:' + objc.key + ',' + msg + '!!'
    return {'ket':{'key':'wwwww'}}
 }
 
function SMSDK()
{
   this.ocTest =  function ocTest(num,msg)
    {
        document.getElementById('msg').innerHTML = '这是我的手机号:' + num + ',' + msg + '!!'
        var obj = new Object();
        obj.name = '叫我山神'
        obj.qq = '1096452045'
        return obj
    }
}
var $smsdk = new SMSDK();

ios中的调用代码

$smsdk.ocTest('18870707070','只能传字符串')   // @"alertSendMsg('18870707070','只能传字符串')"
[self.wkwebV evaluateJavaScript:@"$smsdk.ocTest({key:111},[2000,2001])" completionHandler:^(id _Nullable resp, NSError * _Nullable error) {
    if (error)
    {
        NSLog(@"---error----%@",error);
    }
    else
    {
    NSLog(@"--------resp-------%@",resp);
    }
}];
上面的代码一目了然,第一个参数就是js的方法,主要说说参数回调
resp参数是js返回来的对象,中间的数据转换和上文说的一样
```
#### 2, js调用ios

也非常简单只有一行代码

```
- (void)addScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name;
这个参数是接受回调的代理对象,这个位置不能是控制器的self,可以选自己创建的类,
第二个参数就是js中的方法名字
```
例子:
1, 自己注入js代码(如果自己不注入js代码这一步直接忽略)

```
NSString *javaScriptSource =@"function userFunc(){alert('警告的窗口')}";
WKUserScript *userScript = [[WKUserScript alloc] initWithSource:javaScriptSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
[userController addUserScript:userScript];
```
2, 注册js中的方法名字

```
[userController addScriptMessageHandler:self.objc name:@"showSendMsg"];
[userController addScriptMessageHandler:self.objc name:@"userFunc"];  // 自己注册的方法
```
2.1, js中的代码如下

```
 function btnClick3()
{            
    window.webkit.messageHandlers.showSendMsg.postMessage(['13300001111', '{ww:我是,ee:方法无法}'])
}
showSendMsg 这个就是你 ios代码注册的js的方法
postMessage(a,b) 这个方法接受两个参数,传递参数的规则还是之前说的, 数据类型js和ios有一个对照表,你可以参考之前的文档
```
2.2 ,上面注册代码的时候,第一个参数传了一个遵守代理回调协议的对象,没错回调的数据就是去这个方法获取

```
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:@"showSendMsg"])
    {
        NSArray *array = message.body;
        NSString *info = [NSString stringWithFormat:@"这是我的手机号: %@, %@ !!",array.firstObject,array.lastObject];
     NSLog(info);
    }
}
只有js那边调用方法,发送数据就会走这个方法,ios就可以做响应的处理
```

实际项目的例子:
挖联网APP的js交互,我们约定html所有的需要交互的接口统一调用Call方法,唯一区别就是传递的参数是一个对象,我们在ios会解析成字典,字典中包含了 ClassName 这样的字段,我们根据这个字段动态创建一个类去处理这个js交互的数据

至此我们所有的交互就搞定了,是不是觉得非常的简单呢!

之前的文档:
https://www.jianshu.com/p/c7a7c2211be7
本文档Demo
https://github.com/wangjinshan/JSCDemo


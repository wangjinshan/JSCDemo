//
//  ViewController.m
//  OC与JS交互之WKWebView
//
//  Created by user on 16/8/18.
//  Copyright © 2016年 rrcc. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

#import "IJSTestController.h"

@interface ViewController () <WKScriptMessageHandler,WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property(nonatomic,strong) WKWebView *wkwebV;  // 参数说明
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    // 进程池配置
    WKWebViewConfiguration  * config = [[WKWebViewConfiguration alloc]init];
    // WKProcessPool类中没有暴露任何属性和方法，配置为同一个进程池的WebView会共享数据，例如Cookie、用户凭证等，开发者可以通过编写管理类来分配不同维度的WebView在不同进程池中。
    WKProcessPool * pool = [[WKProcessPool alloc]init];
    config.processPool = pool;
    
    WKPreferences * preference = [[WKPreferences alloc]init]; //进行偏好设置
    preference.minimumFontSize = 5;   //最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
    preference.javaScriptEnabled = YES;  //设置是否支持javaScript 默认是支持的
    preference.javaScriptCanOpenWindowsAutomatically = YES; //设置是否允许不经过用户交互由javaScript自动打开窗口
    config.preferences = preference;
    
    //设置内容交互控制器 用于处理JavaScript与native交互
    WKUserContentController * userController = config.userContentController;
    //设置处理代理并且注册要被js调用的方法名称
    [userController addScriptMessageHandler:self name:@"ijs"];
    //js注入，注入一个测试方法。
    NSString *javaScriptSource =@"function userFunc(){alert('警告的窗口')}";
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:javaScriptSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    // forMainFrameOnly:NO(全局窗口)，yes（只限主窗口）
    [userController addUserScript:userScript];
    config.userContentController = userController;
    
    self.wkwebV =[[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height / 2) configuration:config];

    [self.view addSubview:self.wkwebV];
    self.wkwebV.navigationDelegate = self;
    self.wkwebV.UIDelegate = self;
    
//    NSString *filePath = @"http://xcqbtest.xcqb.cn/#/qa"; //[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *baseURL = [[NSBundle mainBundle] bundleURL];
    [self.wkwebV loadHTMLString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] baseURL:baseURL];
//    [self.wkwebV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:filePath]]];
//    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:filePath]];//[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.xinhuanet.com/politics/2018-05/09/c_1122808419.htm"]];
//    [self.wkwebV loadRequest:request];
    
    //JS调用OC 添加处理脚本
    [userController addScriptMessageHandler:self name:@"name"];
    [userController addScriptMessageHandler:self name:@"showName"];
    [userController addScriptMessageHandler:self name:@"showSendMsg"];
  [userController addScriptMessageHandler:self name:@"userFunc"];
    
//    [self.wkwebV addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        IJSTestController *vc =[IJSTestController new];
        [self presentViewController:vc animated:YES completion:nil];
    });
//    WKSnapshotConfiguration *snap =[[WKSnapshotConfiguration alloc]init];
//    snap.rect = CGRectMake(100, 100, 100, 100);
//    [self.wkwebV takeSnapshotWithConfiguration:snap completionHandler:^(UIImage * _Nullable snapshotImage, NSError * _Nullable error) {
//        UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(50, 50, 300, 300)];
//        imageV.image = snapshotImage;
//        [self.wkwebV addSubview:imageV];
//    }];
//
}

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame])
    {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    // alert弹出框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"---------------%@",self.wkwebV.title);
}


//网页加载完成之后调用JS代码才会执行，因为这个时候html页面已经注入到webView中并且可以响应到对应方法

- (IBAction)btnClick:(UIButton *)sender
{
    if (!self.wkwebV.loading)
    {
        if (sender.tag == 123)
        {
            [self.wkwebV evaluateJavaScript:@"userFunc()" completionHandler:^(id _Nullable response, NSError * _Nullable error) {

            }];
//            [self.wkwebV evaluateJavaScript:@"ocTest" completionHandler:^(id _Nullable resp, NSError * _Nullable error) {
//
//                NSLog(@"%@",err)
//            }];
        }

        if (sender.tag == 234)
        {
            [self.wkwebV evaluateJavaScript:@"alertName('小红')" completionHandler:nil];
        }
        
        if (sender.tag == 345)
        {
            [self.wkwebV evaluateJavaScript:@"alertSendMsg('18870707070','只能传字符串')" completionHandler:^(id _Nullable resp, NSError * _Nullable error) {
                if (error)
                {
                    NSLog(@"---error----%@",error);
                }
                else
                {
                    NSLog(@"%@",resp);
                }
            }];
        }
    } else {
        NSLog(@"the view is currently loading content");
    }
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"-----1-------%@",NSStringFromSelector(_cmd));
    NSLog(@"----2-----%@",[message.body class]);

    if ([message.name isEqualToString:@"showMobile"])
    {
        [self showMsg:@"我是下面的小红 手机号是:18870707070"];
    }
    
    if ([message.name isEqualToString:@"showName"])
    {
        NSString *info = [NSString stringWithFormat:@"你好 %@, 很高兴见到你",message.body];
        [self showMsg:info];
    }
    
    if ([message.name isEqualToString:@"showSendMsg"])
    {
        NSArray *array = message.body;
        NSString *info = [NSString stringWithFormat:@"这是我的手机号: %@, %@ !!",array.firstObject,array.lastObject];
//        [self showMsg:info];
    }
}

- (void)showMsg:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

- (IBAction)clear:(id)sender
{
    [self.wkwebV evaluateJavaScript:@"clear()" completionHandler:nil];
}

/*
 1. WKUserContentController:
 
 专门用来管理native与JavaScript的交互行为，addScriptMessageHandler:name:方法来注册要被js调用的方法名称，之后再JavaScript中使用window.webkit.messageHandlers.name.postMessage()方法来像native发送消息，支持OC中字典，数组，NSNumber等原生数据类型，JavaScript代码中的name要和上面注册的相同。在native代理的回调方法中，会获取到JavaScript传递进来的消息
 
 WKScriptMessage:  类是JavaScript传递的对象实例
 属性
 //传递的消息主体
 @property (nonatomic, readonly, copy) id body;
 //传递消息的WebView
 @property (nullable, nonatomic, readonly, weak) WKWebView *webView;
 //传递消息的WebView当前页面对象
 @property (nonatomic, readonly, copy) WKFrameInfo *frameInfo;
 //消息名称
 @property (nonatomic, readonly, copy) NSString *name;
 
 
 */

-(void)dealloc
{
    NSLog(@"------------");
}

@end






















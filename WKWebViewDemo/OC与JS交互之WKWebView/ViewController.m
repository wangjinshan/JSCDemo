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
#import "IJSTestObjc.h"

@interface ViewController () <WKUIDelegate,WKNavigationDelegate>

@property(nonatomic,strong) WKWebView *wkwebV;  // 参数说明
@property(nonatomic,strong) IJSTestObjc *objc;  // 参数说明
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.objc = [IJSTestObjc new];
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
    [userController addScriptMessageHandler:self.objc name:@"ijs"];
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
//    [self.wkwebV loadHTMLString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] baseURL:baseURL];
//    [self.wkwebV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:filePath]]];
//    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:filePath]];//[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.xinhuanet.com/politics/2018-05/09/c_1122808419.htm"]];
//    [self.wkwebV loadRequest:request];
    
    // 加载本地的html
    NSString *html =[NSString stringWithFormat:@"%@%@",[self _getHtml],[self _getCssString]];
    [self.wkwebV loadHTMLString:html baseURL:nil];
    
    //JS调用OC 添加处理脚本
    [userController addScriptMessageHandler:self.objc name:@"name"];
    [userController addScriptMessageHandler:self.objc name:@"showName"];
    [userController addScriptMessageHandler:self.objc name:@"showSendMsg"];
  [userController addScriptMessageHandler:self.objc name:@"userFunc"];  // 自己注册的方法
    
//    [self.wkwebV addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        IJSTestController *vc =[IJSTestController new];
//        [self presentViewController:vc animated:YES completion:nil];
//    });
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
            [self.wkwebV evaluateJavaScript:@"alertMobile()" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                NSLog(@"---alertMobile----%@",response);
            }];
            
            [self.wkwebV evaluateJavaScript:@"userFunc()" completionHandler:^(id _Nullable resp, NSError * _Nullable error) {

                
            }];
        }

        if (sender.tag == 234)
        {
            [self.wkwebV evaluateJavaScript:@"alertName('小红')" completionHandler:nil];
        }
        
        if (sender.tag == 345)
        {

//            $smsdk.ocTest('18870707070','只能传字符串')   // @"alertSendMsg('18870707070','只能传字符串')"
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
        }
    } else {
        NSLog(@"the view is currently loading content");
    }
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

-(NSString *)_getCssString
{
//    return @"<style>*{font-size: 50px;}.btn{height:80px; width:80%; padding: 0px 30px; background-color: #0071E7; border: solid 1px #0071E7; border-radius:5px; font-size: 1em; color: white}</style>";
    
//    return @"<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=1\"><style>body{margin:0; font-family: \"STHeiti\", \"Microsoft YaHei\", Helvetica, Arial, sans-serif !important;}h1,h2,h3,h4,h5,h6,p,strong,ul,a{text-decoration: none;margin:10px 0px 10px 0px;color:#232426;font-size:21px;line-height: 1.8;text-align:justify}img{height:auto!important;max-width:100%!important}ul{margin-left:20px;list-style:initial}ul li{line-height: 1.8}div{color:#232426;font-size:21px;line-height: 1.8}.f1,.f2,.f3,.f3 span{display:block;font-size:21px;line-height: 1.8;color:#232426}.f1,.f2,.f3,.f3 img{width:20px}</style>";
    
    //return @"<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=1\"><style>body{margin:0; font-family: \"STHeiti\", \"Microsoft YaHei\", Helvetica, Arial, sans-serif !important;}h1,h2,h3,h4,h5,h6,p,strong,ul,a{text-decoration: none;margin:10px 0px 10px 0px;color:#232426;font-size:19px;line-height:1.8;text-align:justify}img{height:auto!important;max-width:100%!important}ul{margin-left:28px;list-style:initial}ul li{line-height: 1.8}div{color:#232426;font-size:19px;line-height:1.8}.f1,.f2,.f3,.f3 span{display:block;font-size:19px;line-height: 1.8;color:#232426}.f1,.f2,.f3,.f3 img{width:28px}</style>";
    
    return @"<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=1\"><style>body{margin:0; font-family: \"STHeiti\", \"Microsoft YaHei\", Helvetica, Arial, sans-serif !important;}h1,h2,h3,h4,h5,h6,p,strong,ul,a{text-decoration: none;margin:10px 0px 10px 0px;color:#232426;font-size:15px;line-height:1.8;text-align:justify}img{height:auto!important;max-width:100%!important}ul{margin-left:20px;list-style:initial}ul li{line-height:1.8}div{color:#232426;font-size:15px;line-height:1.8}.f1,.f2,.f3,.f3 span{display:block;font-size:15px;line-height:1.8;color:#232426}.f1,.f2,.f3,.f3 img{width:20px}</style>";
    
}

-(NSString *)_getHtml
{
    
    return @"<p>这个是P标签的测试</p><div id='wl-anchor-div'>这个是啥</div>";
    
 return @"<div><label>本地测试的html：13300001111</label></div><br/><div id=\"mobile\"></div><div><button class=\"btn\" type=\"button\" onclick=\"btnClick1()\">小红的手机号</button></div><br/><div id=\"name\"></div><div><button class=\"btn\" type=\"button\" onclick=\"btnClick2()\">打电话给小红</button></div><br/><div id=\"msg\"></div><div><button class=\"btn\" type=\"button\" onclick=\"btnClick3()\">发短信给小红</button></div>";
}


-(void)dealloc
{
    NSLog(@"------------");
}

@end






















# JSCDemo
ios与js交互demo
### 认识JavaScriptCore.framework
简书地址:http://www.jianshu.com/p/c7a7c2211be7
####  项目演示

![11.gif](http://upload-images.jianshu.io/upload_images/2845360-ac2e6d5ac71ece40.gif?imageMogr2/auto-orient/strip)
![94E8E789-02BE-4C1B-80A0-B5272F19BA47.png](http://upload-images.jianshu.io/upload_images/2845360-fecc50801af55aa2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![107BFC2C-26E3-4395-BE81-8EFD558D3F52.png](http://upload-images.jianshu.io/upload_images/2845360-95351fbd2ddb914d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
#### 正文
JavaScriptCore.framework 是苹果在ios7之后新增的框架,是对 UIWebView的一次封装,方便开发者使用,使用JavaScriptCore.framework可以轻松实现 ios与js的交互 
##### JavaScriptCore的组成
JavaScriptCore中主要的类
![java.png](http://upload-images.jianshu.io/upload_images/2845360-8a05a212578bf2db.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
详细介绍
1, JSContext --- 在OC中创建JavaScript运行的上下文环境

```
// 创建JSContext对象，获得JavaScript运行的上下文环
- (instancetype)init; 
// 在特定的对象空间上创建JSContext对象，获得JavaScript运行的上下文环境
- (instancetype)initWithVirtualMachine:(JSVirtualMachine *)virtualMachine;
// 运行一段js代码，输出结果为JSValue类型
- (JSValue *)evaluateScript:(NSString *)script;
// iOS 8.0以后可以调用此方法
- (JSValue *)evaluateScript:(NSString *)script withSourceURL:(NSURL *)sourceURL NS_AVAILABLE(10_10, 8_0);
// 获取当前正在运行的JavaScript上下文环境
+ (JSContext *)currentContext;
// 返回结果当前执行的js函数 function () { [native code] } ，iOS 8.0以后可以调用此方法
+ (JSValue *)currentCallee NS_AVAILABLE(10_10, 8_0);
// 返回结果当前方法的调用者[object Window]
+ (JSValue *)currentThis;
// 返回结果为当前被调用方法的参数
+ (NSArray *)currentArguments;
// js的全局变量 [object Window]
@property (readonly, strong) JSValue *globalObject;
// 返回js 调用时候的异常信息
@property (copy) void(^exceptionHandler)(JSContext *context, JSValue *exception);
//  异常捕获中错误值处理
@property (strong) JSValue *exception;
// 上下文的名字
@property (copy) NSString *name NS_AVAILABLE(10_10, 8_0);
```
JSValue --- JavaScript中的变量和方法，可以转成OC数据类型,每个JSValue都和JSContext相关联并且强引用context
OC 和 js 数据对照表

| Objective-C type |  JavaScript type |
| --- | --- |
| nil  | undefined |
| NSNull  |  null |
| NSString | string |
| NSNumber  | number, boolean |
| NSDictionary | Object object |
| NSArray |  Array object |
| NSDate |  Date object |
| NSBlock (1)  | Function object (1) |
| id (2)  | Wrapper object (2) |
|  Class (3)  | Constructor object (3) |

```
// 在context创建BOOL的JS变量
+ (JSValue *)valueWithBool:(BOOL)value inContext:(JSContext *)context;
// 修改JS对象的属性的值
- (void)setValue:(id)value forProperty:(NSString *)property;
// 调用者JSValue对象为JS中的方法名称，arguments为参数，调用JS中Window直接调用的方法
- (JSValue *)callWithArguments:(NSArray *)arguments;
// 调用者JSValue对象为JS中的全局对象名称，method为全局对象的方法名称，arguments为参数
- (JSValue *)invokeMethod:(NSString *)method withArguments:(NSArray *)arguments;
// JS中的结构体类型转换为OC
+ (JSValue *)valueWithPoint:(CGPoint)point inContext:(JSContext *)context;
// 将JS变量转换成OC中的BOOL类型/提供了其他方法的转换
- (BOOL)toBool;
 // JS中是否有这个对象
// @property (readonly) BOOL isUndefined;
// 比较两个JS对象是否相等
- (BOOL)isEqualToObject:(id)value;
```
3, JSExport --- JS调用OC中的方法和属性写在继承自JSExport的协议当中，OC对象实现自定义的协议

```
官方给的例子
//@textblock
    @protocol MyClassJavaScriptMethods <JSExport>
    - (void)foo;
    @end
  // 方法实现
    @interface MyClass : NSObject <MyClassJavaScriptMethods>
    - (void)foo;
    - (void)bar;
    @end
//@/textblock
```
4, JSManagedValue --- JS和OC对象的内存管理辅助对象,主要用来保存JSValue对象,解决OC对象中存储js的值，导致的循环引用问题

```
// 初始化
- (instancetype)initWithValue:(JSValue *)value;
+ (JSManagedValue *)managedValueWithValue:(JSValue *)value;
+ (JSManagedValue *)managedValueWithValue:(JSValue *)value andOwner:(id)owner NS_AVAILABLE(10_10, 8_0);
```
**JSManagedValue本身只弱引用js值，需要调用JSVirtualMachine的addManagedReference:withOwner:把它添加到JSVirtualMachine中，这样如果JavaScript能够找到该JSValue的Objective-C owner，该JSValue的引用就不会被释放**。

5, JSVirtualMachine --- JS运行的虚拟机，有独立的堆空间和垃圾回收机制，运行在不同虚拟机环境的JSContext可以通过此类通信。

```
// 初始化
- (instancetype)init;
// 添加
- (void)addManagedReference:(id)object withOwner:(id)owner;
 //  移除
 - (void)removeManagedReference:(id)object withOwner:(id)owner;
```
到此 JavaScriptCore.framework 能够使用的基本api已经介绍完毕
<hr>
下面我们以简单集成SMSDK为 实际例子进行讲解
首先创建必要的三个文件 SMSDK.html/ SMSDK.cc SMSDK.js 在viewDidLoad中创建webview进行加载SDMSDK.html
#### iOS调用 js

![jsios.png](http://upload-images.jianshu.io/upload_images/2845360-3ad5a055a460bc13.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
js中方法的实现

```
在 SMSDK.js中 创建 ios需要的初始化对象 并保留一个 对象接口  方便在 html中 调用这个方法
SMSDK.js
function SMSDK()
{
//    不能添加 alert() 等外部的方法
//    alert(--qq--);
    var name = "金山";
    this.initSDK = function (hello)
    {
        var initData ={};
        var appkey =
            {
            "appkey":"f3fc6baa9ac4"
            }
        var appSecrect=
            {
            "appSecrect":"7f3dedcb36d92deebcb373af921d635a"
            }
        initData["appkey"] = appkey;
        initData["appSecrect"] = appSecrect;
        return initData;
    };
//    必须使用this 关键字
}
var $smsdk = new SMSDK();
在 SMSDK.html中进行引用并 创建js 方法
         <script>
            function initSDK(hello)
            {
                return $smsdk.initSDK(hello);
            }
            </script>
            这里的 initSDK(); 方法就是留给ios 调用的方法
```
我们同样选择在网页加载完成的方法中进行方法调用 

```
-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    [self initSMSDK];
}
实现 方法
-(void) initSMSDK
{
//    创建上下文
// 1.这种方式需要传入一个JSVirtualMachine对象，如果传nil，会导致应用崩溃的。
   JSVirtualMachine *JSVM = [[JSVirtualMachine alloc] init];
   JSContext *jscontext = [[JSContext alloc] initWithVirtualMachine:JSVM];
     2.这种方式，内部会自动创建一个JSVirtualMachine对象，可以通过JSCtx.virtualMachine
    // 看其是否创建了一个JSVirtualMachine对象。
   JSContext *jscontext = [[JSContext alloc] init];
/**********以上的方法经过测试都不好使*************/
   正确的姿势 
1,   创建上下文,意思就是让oc和js 同处于一个环境,方便进行方法调用
    JSContext *jscontext = [self.mywebview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
2   参数接受  注意一定输传递方法的名字,不要加()// 和webview的调用方法的区别
    JSValue *jsvalue = jscontext[@"initSDK"];   // 返回的是方法的名字和内容
3  调用函数/传递参数
  JSValue *initData = [jsvalue callWithArguments:@[@"从oc中传递第一个参数进去"]];
  接收到的字典对象进行解析,并调用SMSDK的初始化方法 
  NSDictionary *dic = [initData toDictionary];
    NSString *appkey = dic[@"appkey"][@"appkey"];
    NSString  *appSecrect = dic[@"appSecrect"][@"appSecrect"];
    [SMSSDK registerApp:appkey withSecret:appSecrect];
}
```
我们通过打印上面的 appkey 等参数就知道 实现了ios调用 js的方法

#### js调用 ios

可以通过两种方式在JavaScript中调用Objective-C：
Blocks： 对应JS函数
JSExport协议： 对应JS对象
我们先实现 block的方法

Block的方法
首先在html中 写一个button的点击方法  

```
 <button id="getCode" onclick="getCode($smsdk.getCode())">获取手机号</button>
```
getCode()方法就是将来 ios 中需要注册的方法体, 里面是对js返回参数方法的调用 相当于 getCode('返回给js的参数,在参数列表中调用就可以');

```
过程和上面一样 
// 1,获取上下文  // 下文weakSelf.jsContext 中已经在属性中保存jscontext
JSContext *_jsContext = [self.mywebview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
 // 2 异常捕获机制
    _jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        context.exception = exception;
        //别忘了给exception赋值，否则JSContext的异常信息为空
        NSLog(@"---错误数据的处理----%@",exception);
    };
      __weak typeof (self) weakSelf = self; // 防止循环引用就加上 __weak
_jsContext[@"getCode"] = ^ (){

        NSArray *arr =[JSContext currentArguments]; // 获取当前的上下文,然后加载 js返回的参数列表
        for (id objc in arr) {
            weakSelf.phoneNumber = objc;
            [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:objc zone:@"86" customIdentifier:nil result:^(NSError *error) {
                JSContext *jscontext = weakSelf.jsContext;
                if (!error)
                {
                //  ios回调 js的代码 并传递参数给 js
                    JSValue *jsvalue = jscontext[@"getCodeCallBack"]; // 注入方法
                  [jsvalue callWithArguments:@[@"获取短信验证码成功"]];                               // 调用方法
                 }
                else
                {
                    JSValue *jsvalue = jscontext[@"getCodeCallBack"]; // 注入方法
                    [jsvalue callWithArguments:@[@"获取验证码失败"]];
                }
            }];
        }
    };
```
通过上面的方法我们知道, block 方法 ios 给 js传递的是方法 ,如果传递 对象则需要用到 协议的方法 
首先我们来看一个最简单的例子 :
在 js 上写一个 点击事件,然后调用 ios 的方法
在 js中 

```
在 SMDK.html中添加 
<div>
    <input type= "button" width="50%" height="5%" id = "Button" value = "需要测试" onclick = "objc.takePicture()"></button>
</div>
说明:  这里的 objc 对象就是将来我们需要在 ios中注册的对象, takePicture() ,就是在协议中的方法
```
在viewController.m中,定义协议

```
/**
 *  实现js代理，js调用ios的入口就在这里
 */
@protocol JSDelegate <JSExport>

- (void)getImage:(id)parameter;// 这个方法就是window.document.iosDelegate.getImage(JSON.stringify(parameter)); 中的 getImage()方法

@end
```
签订协议:  注意这里的协议不需要实现,在外部也不需要设置代理,直接实现就可以

```
@interface ViewController ()<UIWebViewDelegate,JSDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,JSOCViewControllerExport>
```
在网页加载完成的代理中实现, 上下文

```
    self.jsContext = [self.myWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//    测试处理
    self.jsContext[@"objc"] = self;//挂上代理  iosDelegate是window.document.iosDelegate.getImage(JSON.stringify(parameter)); 中的 iosDelegate
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception){
        context.exception = exception;
        NSLog(@"js方法写错了 错误的信息都会在此处输出：%@",exception);
    };
```
最后一步就是实现 在 js中声明的协议方法

```
//  协议实现
- (void)getImage:(id)parameter
{
    NSArray *arr =[JSContext currentArguments];
    for (id objc in arr)
    {
        NSLog(@"=-----%@",[objc toDictionary]);
    }
    [self beginOpenPhoto];  // 相机的处理,
}
```
实现相机的方法,很简单, 里面的数据传递和上文中说到的一个样子,这里将不再赘述.
到此, 利用协议实现 js 调用 ios的方法基本完成

关于内存泄漏,循环引用的问题 注意不要在 block中直接 引用外部 强引用的对象就可以

```
 __weak typeof (self) weakSelf = self; // 防止循环引用就加上 __weak
    _jsContext[@"getCode"] = ^ (id oc){
        NSArray *arr =[JSContext currentArguments]; // 获取当前的上下文
        for (id objc in arr) {
            weakSelf.phoneNumber = objc;
这个  weakSelf 的处理就ok
```

简书地址:http://www.jianshu.com/p/c7a7c2211be7
<hr>

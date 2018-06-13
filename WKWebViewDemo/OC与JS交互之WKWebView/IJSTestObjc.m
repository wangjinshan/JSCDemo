

//
//  IJSTestObjc.m
//  OC与JS交互之WKWebView
//
//  Created by 山神 on 2018/6/12.
//  Copyright © 2018年 rrcc. All rights reserved.
//

#import "IJSTestObjc.h"


@interface IJSTestObjc()

@end

@implementation IJSTestObjc


- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask
{
    
}

- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask
{
    
}


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"-----1-------%@",NSStringFromSelector(_cmd));
    NSLog(@"----2-----%@",[message.body class]);
    
}












@end

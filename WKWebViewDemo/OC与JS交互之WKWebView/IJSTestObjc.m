

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


#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
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
        [self showMsg:info];
    }
}

- (void)showMsg:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}












@end

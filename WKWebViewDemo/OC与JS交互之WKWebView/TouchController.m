
//
//  TouchController.m
//  OC与JS交互之WKWebView
//
//  Created by 山神 on 2018/6/13.
//  Copyright © 2018年 rrcc. All rights reserved.
//

#import "TouchController.h"

@interface TouchController ()

@end

@implementation TouchController

- (void)viewDidLoad
{
    [super viewDidLoad];
  
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems
{
    return self.itemArr;
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"测试1" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction *_Nonnull action, UIViewController *_Nonnull previewViewController) {

    }];
    
    UIPreviewAction *collection = [UIPreviewAction actionWithTitle:@"测试2" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction *_Nonnull action, UIViewController *_Nonnull previewViewController) {
       
    }];
    
    //    UIPreviewAction *export = [UIPreviewAction actionWithTitle:[NSBundle localizedStringForKey:@"Export"] style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
    //
    //        if (self.model.type== JSAssetModelMediaTypeVideo)
    //        {
    //
    //          [[IJSImageManager shareManager]getVideoOutputPathWithAsset:self.model.asset completion:^(NSString *outputPath) {
    //               [self  showAlertWithTitle:@"导出成功" ];
    //          }];
    //        }else{
    //            [self  showAlertWithTitle:@"功能未开发" ];
    //        }
    //
    //    }];
    
    //    UIPreviewAction *Edit = [UIPreviewAction actionWithTitle:[NSBundle localizedStringForKey:@"Edit"] style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
    //
    //        [self  showAlertWithTitle:@"功能开发" ];
    //    }];
    
    NSArray *actions = @[action1, collection];
    return actions;
}

@end

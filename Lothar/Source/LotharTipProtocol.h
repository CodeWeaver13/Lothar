//
//  LotharTipProtocol.h
//  Lothar
//
//  Created by wangshiyu13 on 2016/12/12.
//  Copyright © 2016年 mykj. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LotharTipProtocol <NSObject>
/**
 外部调用URL参数错误时默认的提示VC
 */
- (nonnull UIViewController *)paramsErrorTipController;

/**
 内部调用找不到控制器时的提示VC
 */
- (nonnull UIViewController *)notFoundTargetTipController;

/**
 内部调用无法解析参数时的提示VC
 */
- (nonnull UIViewController *)notFoundActionTipController;

@end

//
//  LotharExceptionProtocol.h
//  Lothar
//
//  Created by wangshiyu13 on 2016/12/12.
//  Copyright © 2016年 mykj. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LotharExceptionProtocol <NSObject>

/**
 处理调度器无法解析URL时的代理方法

 @param url 远程调用的URL
 */
- (void)mediatorCannotParseWithURL:(NSURL *)url;

/**
 处理调度器无法匹配URLScheme的情况的代理方法
 
 @param url 远程调用的URL
 */
- (void)mediatorCannotMatchSchemeWithURL:(NSURL *)url;

/**
 处理调度器无法匹配URLUser&URLPassword，是否允许继续执行的代理方法
 
 @param aUser 远程调用的用户名
 @param aPassword 远程调用的密码
 @return 是否允许继续执行
 */
- (BOOL)mediatorCannotMatchUserOrPasswordWithUser:(NSString *)aUser
                                      andPassword:(NSString *)aPassword;

@end

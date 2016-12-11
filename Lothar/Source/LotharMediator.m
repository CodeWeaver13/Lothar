//
//  LotharMediator.m
//  Lothar
//
//  Created by wangshiyu13 on 2016/12/12.
//  Copyright © 2016年 mykj. All rights reserved.
//

#import "LotharMediator.h"
#import "LotharConfig.h"

#import "LotharExceptionProtocol.h"
#import "LotharTipProtocol.h"

#import "LotharObject.h"
#import "LotharRouteMapObject.h"

@interface LotharMediator ()
/**
 APP的控制器映射表
 */
@property (nonatomic, strong) LotharRouteMapObject *URLModuleMap;
@end

@implementation LotharMediator
#pragma mark - public methods
+ (instancetype)shared {
    static LotharMediator *mediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[LotharMediator alloc] init];
    });
    return mediator;
}

- (LotharRouteMapObject *)URLModuleMap {
    if (_URLModuleMap == nil) {
        _URLModuleMap = [LotharRouteMapObject mapWithPlistFile:self.config.URLRouteMapFilePath];
    }
    return _URLModuleMap;
}

/*
 scheme://[user]:[password]@[target]/[action]?[params]
 
 url sample:
 myapp://user:password@targetA/actionB?id=1234
 */
- (nonnull id)performActionWithUrl:(NSURL *)url
                        completion:(void (^ _Nullable)(NSDictionary *))completion
{
    LotharObject *obj = [LotharObject parseObjectWithURL:url];
    
    // 如果调用的URL无法解析，则调用exceptionDelegate的mediatorCannotParseWithURL:给出错误的URL
    if (obj == nil) {
        if ([self.exceptionDelegate respondsToSelector:@selector(mediatorCannotParseWithURL:)]) {
            [self.exceptionDelegate mediatorCannotParseWithURL:url];
        }
        return @(NO);
    }
    
    if (![obj.scheme isEqualToString:self.config.URLScheme]) {
        // 如果调用的URL的scheme不匹配，则调用exceptionDelegate的mediatorCannotMatchSchemeWithURL:给出错误的URL
        if ([self.exceptionDelegate respondsToSelector:@selector(mediatorCannotMatchSchemeWithURL:)]) {
            [self.exceptionDelegate mediatorCannotMatchSchemeWithURL:url];
        }
        return @(NO);
    }
    
    while ((![obj.user isEqualToString:self.config.URLUser] || ![obj.password isEqualToString:self.config.URLPassword])
           && (NO == self.config.URLVerifySkip)) {
        // 这里是处理远程调用账号密码错误的处理
        if ([self.exceptionDelegate respondsToSelector:@selector(mediatorCannotMatchUserOrPasswordWithUser:andPassword:)]) {
            BOOL next = [self.exceptionDelegate mediatorCannotMatchUserOrPasswordWithUser:obj.user
                                                                              andPassword:obj.password];
            if (next) {
                break;
            }
        }
        return @(NO);
    }
    
    // 对URL的路由处理由URLModuleMap路由表完成，路由表内映射短链和Target/Action之间的关系
    id result = [self performTarget:self.URLModuleMap[obj.target].targetName
                             action:self.URLModuleMap[obj.target][obj.action].actionName
                             params:obj.params];
    if (completion) {
        if (result) {
            completion(@{@"result":result});
        } else {
            completion(nil);
        }
    }
    return result;
}

- (nonnull id)performTarget:(NSString *)targetName
                     action:(NSString *)actionName
                     params:(NSDictionary *)params
{
    NSString *targetClzStr = [NSString stringWithFormat:@"Target_%@", targetName];
    NSString *actionStr = [NSString stringWithFormat:@"Action_%@:", actionName];
    
    Class targetClass = NSClassFromString(targetClzStr);
    id target = [[targetClass alloc] init];
    SEL action = NSSelectorFromString(actionStr);
    
    // 如果target有误，则通过tipDelegate的notFoundTargetTipController方法返回提示VC
    if (target == nil) {
        if ([self.tipDelegate respondsToSelector:@selector(notFoundTargetTipController)]) {
            return [self.tipDelegate notFoundTargetTipController];
        }
    }
    
    if ([target respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
    } else {
        // 这里是处理无响应请求的地方，如果无响应，则尝试调用对应target的notFound方法统一处理
        if ([target respondsToSelector:@selector(notFound:)]) {
            id result = [target performSelector:@selector(notFound:) withObject:params];
            if (result) {
                return result;
            } else {
                // 如果action无法响应，且notFound未实现，则调用tipDelegate的notFoundActionTipController返回提示VC
                if ([self.tipDelegate respondsToSelector:@selector(notFoundActionTipController)]) {
                    return [self.tipDelegate notFoundActionTipController];
                }
            }
        }
    }
    return @(NO);
}

@end

//
//  LotharMediator.m
//  Lothar
//
//  Created by wangshiyu13 on 2016/12/12.
//  Copyright © 2016年 mykj. All rights reserved.
//

#import "Lothar.h"
#import "LotharConfig.h"

#import "LotharExceptionProtocol.h"
#import "LotharTipProtocol.h"

#import "LotharObject.h"
#import "LotharRouteMapObject.h"

@interface Lothar ()
/**
 HLLothar的参数配置
 */
@property (nonatomic, strong, readwrite) LotharConfig *config;
/**
 APP的控制器映射表
 */
@property (nonatomic, strong) LotharRouteMapObject *URLModuleMap;

@property (nonatomic, strong) NSMutableDictionary *targetCache;
@end

@implementation Lothar
#pragma mark - static methods
+ (void)setupConfig:(void(^)(LotharConfig * _Nonnull))config {
    return [[self shared] setupConfig:config];
}

+ (id)performActionWithUrl:(NSURL *)url completion:(void (^)(id _Nullable))completion {
    return [[self shared] performActionWithUrl:url completion:completion];
}

+ (nullable id)performTarget:(NSString *)targetName
                        action:(NSString *)actionName
                        params:(NSDictionary *)params
             shouldCacheTarget:(BOOL)shouldCacheTarget
{
    return [[self shared] performTarget:targetName action:actionName params:params shouldCacheTarget:shouldCacheTarget];
}

+ (void)releaseTargetCacheWithTargetName:(NSString *)targetName {
    [[self shared] releaseTargetCacheWithTargetName:targetName];
}

#pragma mark - public methods
+ (instancetype)shared {
    static Lothar *mediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[Lothar alloc] init];
    });
    return mediator;
}

- (void)setupConfig:(void(^)(LotharConfig * _Nonnull))config {
    !config ? nil : config(self.config);
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
- (id)performActionWithUrl:(NSURL *)url completion:(void (^)(id _Nullable))completion
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
                             params:obj.params
                  shouldCacheTarget:NO];
    
    if (completion) {
        if (result) {
            completion(result);
        } else {
            completion(nil);
        }
    }
    return result;
}

- (nullable id)performTarget:(NSString *)targetName
                     action:(NSString *)actionName
                     params:(NSDictionary *)params
          shouldCacheTarget:(BOOL)shouldCacheTarget
{
    NSString *targetClzStr = [NSString stringWithFormat:@"Target_%@", targetName];
    NSString *actionStr = [NSString stringWithFormat:@"Action_%@:", actionName];
    
    id target = self.targetCache[targetClzStr];
    // 如果target有误，则通过tipDelegate的notFoundTargetTipController方法返回提示VC
    if (target == nil) {
        Class targetClass = NSClassFromString(targetClzStr);
        target = [[targetClass alloc] init];
    }
    SEL action = NSSelectorFromString(actionStr);
    
    if (target == nil) {
        if ([self.tipDelegate respondsToSelector:@selector(notFoundTargetTipController)]) {
            return [self.tipDelegate notFoundTargetTipController];
        }
    }
    
    if (shouldCacheTarget) {
        self.targetCache[targetClzStr] = target;
    }
    
    if ([target respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
    } else {
        // 这里是处理无响应请求的地方，如果无响应，则尝试调用对应target的notFound方法统一处理
        SEL notFound = NSSelectorFromString(@"notFound:");
        if ([target respondsToSelector:notFound]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            return [target performSelector:notFound withObject:params];
#pragma clang diagnostic pop
        } else {
            // 如果action无法响应，且notFound未实现，则调用tipDelegate的notFoundActionTipController返回提示VC
            if ([self.tipDelegate respondsToSelector:@selector(notFoundActionTipController)]) {
                return [self.tipDelegate notFoundActionTipController];
            }
            [self.targetCache removeObjectForKey:targetClzStr];
            return nil;
        }
    }
    return @(NO);
}

- (void)releaseTargetCacheWithTargetName:(NSString *)targetName {
    NSString *targetClassString = [NSString stringWithFormat:@"Target_%@", targetName];
    [self.targetCache removeObjectForKey:targetClassString];
}

- (NSMutableDictionary *)targetCache {
    if (_targetCache == nil) {
        _targetCache = [NSMutableDictionary dictionary];
    }
    return _targetCache;
}

@end

//
//  LotharRouteMapObject.m
//  Lothar
//
//  Created by wangshiyu13 on 2016/12/12.
//  Copyright © 2016年 mykj. All rights reserved.
//

#import "LotharRouteMapObject.h"

#pragma mark - RouteActionObject

@implementation LotharRouteActionObject

- (instancetype)initWithAction:(NSString *)actionName {
    self = [super init];
    if (self) {
        _actionName = actionName;
    }
    return self;
}

@end

#pragma mark - HLRouteTargetObject

@interface LotharRouteTargetObject ()
@property (nonatomic, strong, readwrite) NSMutableDictionary<NSString *, LotharRouteActionObject *> *actionMap;
@end

@implementation LotharRouteTargetObject

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _targetName = [dict valueForKey:@"name"];
        NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
        [[dict valueForKey:@"actions"] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            tmp[key] = [[LotharRouteActionObject alloc] initWithAction:obj];
        }];
        _actionMap = [tmp copy];
    }
    return self;
}

- (nullable LotharRouteActionObject *)objectForKeyedSubscript:(NSString *)key {
    return _actionMap[key];
}
@end

#pragma mark - HLRouteMapObject

@interface LotharRouteMapObject ()
@property (nonatomic, strong, readwrite) NSDictionary<NSString *, LotharRouteTargetObject *> *routeMap;
@end

@implementation LotharRouteMapObject

+ (instancetype)mapWithPlistFile:(NSString *)filePath {
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return [[self alloc] initWithDictionary:plist];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            tmp[key] = [[LotharRouteTargetObject alloc] initWithDictionary:obj];
        }];
        _routeMap = [tmp copy];
    }
    return self;
}

- (nullable LotharRouteTargetObject *)objectForKeyedSubscript:(NSString *)key {
    return _routeMap[key];
}

@end

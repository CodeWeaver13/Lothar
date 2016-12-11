//
//  LotharRouteMapObject.h
//  Lothar
//
//  Created by wangshiyu13 on 2016/12/12.
//  Copyright © 2016年 mykj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *ActionName NS_EXTENSIBLE_STRING_ENUM;

typedef NSString *TargetName NS_EXTENSIBLE_STRING_ENUM;

#pragma mark - HLRouteActionObject

@interface LotharRouteActionObject : NSObject

@property (nonatomic, copy, readonly) ActionName actionName;

@end

#pragma mark - HLRouteTargetObject

@interface LotharRouteTargetObject : NSObject

@property (nonatomic, copy, readonly) TargetName targetName;

- (nullable LotharRouteActionObject *)objectForKeyedSubscript:(NSString *)key;

@end

#pragma mark - HLRouteMapObject

@interface LotharRouteMapObject : NSObject

- (nullable LotharRouteTargetObject *)objectForKeyedSubscript:(NSString *)key;


/**
 创建url短链路由表的工厂方法
 
 @param filePath Plist文件路径
 @return HLRouteMapObject模型对象
 */
+ (instancetype)mapWithPlistFile:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END

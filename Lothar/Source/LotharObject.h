//
//  LotharObject.h
//  Lothar
//
//  Created by wangshiyu13 on 2016/12/12.
//  Copyright © 2016年 mykj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LotharObject : NSObject
@property (nonatomic, copy, readonly) NSString *scheme;

@property (nonatomic, copy, readonly) NSString *user;

@property (nonatomic, copy, readonly) NSString *password;

@property (nonatomic, copy, readonly) NSString *target;

@property (nonatomic, copy, readonly) NSString *action;

@property (nonatomic, strong, readonly) NSDictionary *params;

+ (instancetype)parseObjectWithURL:(NSURL *)url;
@end

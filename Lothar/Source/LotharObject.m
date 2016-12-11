//
//  LotharObject.m
//  Lothar
//
//  Created by wangshiyu13 on 2016/12/12.
//  Copyright © 2016年 mykj. All rights reserved.
//

#import "LotharObject.h"

@interface LotharObject ()
@property (nonatomic, copy, readwrite) NSString *scheme;

@property (nonatomic, copy, readwrite) NSString *user;

@property (nonatomic, copy, readwrite) NSString *password;

@property (nonatomic, copy, readwrite) NSString *target;

@property (nonatomic, copy, readwrite) NSString *action;

@property (nonatomic, strong, readwrite) NSDictionary *params;
@end

@implementation LotharObject

+ (instancetype)parseObjectWithURL:(NSURL *)url {
    return [[LotharObject alloc] initWithURL:url];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.scheme = url.scheme;
        self.user = url.user;
        self.password = url.password;
        self.target = url.host;
        self.action = [url.path componentsSeparatedByString:@"/"].lastObject;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (NSString *param in [url.query componentsSeparatedByString:@"&"]) {
            NSArray *elements = [param componentsSeparatedByString:@"="];
            if([elements count] < 2) continue;
            [dict setObject:[elements lastObject] forKey:[elements firstObject]];
        }
        self.params = [dict copy];
    }
    return self;
}
@end

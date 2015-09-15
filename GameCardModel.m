//
//  GameCardModel.m
//  自写项目02sanguosha
//
//  Created by Apple on 15/9/5.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "GameCardModel.h"

@interface GameCardModel ()

@end

@implementation GameCardModel

+ (instancetype)gameCardModelWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        // 属性名与字典中key不匹配，手动转模型
        self.cardID = dict[@"CardID"];
        self.clazz = dict[@"Class"];
        self.color = dict[@"Color"];
        self.imageID = dict[@"ImageID"];
        self.name = dict[@"Name"];
        self.number = dict[@"Number"];
        self.typeID = dict[@"TypeID"];
    }
    return self;
}

@end

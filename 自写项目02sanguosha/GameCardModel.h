//
//  GameCardModel.h
//  自写项目02sanguosha
//
//  Created by Apple on 15/9/5.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameCardModel : NSObject

@property (nonatomic,copy) NSString *cardID;

@property (nonatomic,copy) NSString *clazz;

@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *number;

@property (nonatomic,copy) NSString *color;

@property (nonatomic,copy) NSString *typeID;

@property (nonatomic,copy) NSString *imageID;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)gameCardModelWithDict:(NSDictionary *)dict;


@end

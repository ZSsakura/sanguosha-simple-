//
//  Player.h
//  自写项目02sanguosha
//
//  Created by Apple on 15/9/7.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

/*
 游戏角色
 需求属性:判定牌，手牌，装备牌，角色名称
 游戏属性:血量，角色位置(判断角色距离需要使用)
 
 */

#import <Foundation/Foundation.h>

@class GameCardModel;
@interface Player : NSObject

@property (nonatomic,copy) NSString *name;

@property (nonatomic,strong) NSMutableArray *handCards;
@property (nonatomic,strong) NSMutableArray *judgeCards;
@property (nonatomic,strong) NSMutableArray *equipCards;

@property (nonatomic,assign) int blood;
@property (nonatomic,assign) int position;

// 一个玩家，控制一个游戏画面
@property (nonatomic,weak) UIView *playView;

- (void)handCardsAddCard:(GameCardModel *)card;
- (void)handCardsRemoveCard:(GameCardModel *)card;

- (void)enterMainStage;
- (void)enterEndStage;

// 询问游戏控制器是否有可攻击单位
@property (nonatomic,copy) BOOL(^isAttackEnableBlock)(Player *player);

// 角色被“杀”
- (void)getAttacked;

// 手牌被使用(告知控制器)
@property (nonatomic,copy) void(^useCardBlock)(Player *player,GameCardModel *card);

// 表示游戏者是否可以出杀
@property (nonatomic,assign) BOOL isShaCanBeUsed;

// 提供一个方法检索手牌
- (GameCardModel *)handCardsHasCard:(NSString *)cardClazz;

@property (nonatomic,copy) void(^playerOtherEndMainStageBlock)();

@end

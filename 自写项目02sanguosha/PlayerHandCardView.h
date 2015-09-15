//
//  PlayerHandCardView.h
//  自写项目02sanguosha
//
//  Created by Apple on 15/9/7.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

// 用户手牌视图

#import <UIKit/UIKit.h>

@class GameCardModel;
@interface PlayerHandCardView : UIView
// 保存GameCardModel
@property (nonatomic,strong) NSMutableArray *handCards;

@property (nonatomic,assign) NSInteger handCardsCanSelectedCount;
// 保存GameCardView
@property (nonatomic,strong) NSMutableArray *selectedHandCards;

- (void)addCard:(GameCardModel *)card;
- (void)removeCard:(GameCardModel *)card;

- (void)enterMainStage:(NSDictionary *)info;
- (void)enterEndStage;

@end

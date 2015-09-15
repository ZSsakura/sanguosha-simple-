//
//  PlayerSelfView.h
//  自写项目02sanguosha
//
//  Created by Apple on 15/9/7.
//  Copyright (c) 2015年 Apple. All rights reserved.


//  用户进行游戏的视图

#import <UIKit/UIKit.h>

@class GameCardModel;
@class PlayerBaseView,PlayerHandCardView;

@interface PlayerSelfView : UIView

@property (nonatomic,strong) PlayerBaseView *baseView;

@property (nonatomic,strong) PlayerHandCardView *handCardView;

- (void)playerSelfViewAddHandCard:(GameCardModel *)card;
- (void)playerSelfViewRemoveHandCard:(GameCardModel *)card;

- (void)setHandCardCanSelectedCount:(NSInteger)count;

- (void)enterMainStage:(NSDictionary *)info;
- (void)enterEndStage;

@end

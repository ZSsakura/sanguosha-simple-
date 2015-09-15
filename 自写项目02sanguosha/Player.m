//
//  Player.m
//  自写项目02sanguosha
//
//  Created by Apple on 15/9/7.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "Player.h"
#import "PlayerSelfView.h"
#import "PlayerBaseView.h"
#import "GameCardModel.h"

@implementation Player

- (NSMutableArray *)handCards {
    if (!_handCards) {
        _handCards = [NSMutableArray array];
    }
    return _handCards;
}

- (NSMutableArray *)judgeCards {
    if (!_judgeCards) {
        _judgeCards = [NSMutableArray array];
    }
    return _judgeCards;
}

- (NSMutableArray *)equipCards {
    if (!_equipCards) {
        _equipCards = [NSMutableArray array];
    }
    return _equipCards;
}

- (void)handCardsAddCard:(GameCardModel *)card {
    [self.handCards addObject:card];
    
    if ([self.playView isKindOfClass:[PlayerSelfView class]]) {
        PlayerSelfView *view = (PlayerSelfView *)self.playView;
        [view playerSelfViewAddHandCard:card];
        view.baseView.handCardsCount = self.handCards.count;
    }else {
        PlayerBaseView *view = (PlayerBaseView *)self.playView;
        view.handCardsCount = self.handCards.count;
    }
}

- (void)handCardsRemoveCard:(GameCardModel *)card {
    [self.handCards removeObject:card];
    if ([self.playView isKindOfClass:[PlayerSelfView class]]) {
        PlayerSelfView *view = (PlayerSelfView *)self.playView;
        [view playerSelfViewRemoveHandCard:card];
        view.baseView.handCardsCount = self.handCards.count;
    }else {
        PlayerBaseView *view = (PlayerBaseView *)self.playView;
        view.handCardsCount = self.handCards.count;
    }
}

- (void)setName:(NSString *)name {
    _name = [name copy];
    
    if ([self.playView isKindOfClass:[PlayerSelfView class]]) {
        PlayerSelfView *view = (PlayerSelfView *)self.playView;
        view.baseView.playerName = name;
    }else {
        PlayerBaseView *view = (PlayerBaseView *)self.playView;
        view.playerName = name;
    }
}

- (void)setBlood:(int)blood {
    _blood = blood;
    if ([self.playView isKindOfClass:[PlayerSelfView class]]) {
        PlayerSelfView *view = (PlayerSelfView *)self.playView;
        view.baseView.blood = blood;
    }else {
        PlayerBaseView *view = (PlayerBaseView *)self.playView;
        view.blood = blood;
    }
    if (_blood <= 0) {
        NSLog(@"角色%@濒死",self.name);
        [[NSNotificationCenter defaultCenter] postNotificationName:PlayerIsDying object:self];
    }
}

- (void)enterMainStage {
    
    if ([self.playView isKindOfClass:[PlayerSelfView class]]) {
        PlayerSelfView *view = (PlayerSelfView *)self.playView;
        
        BOOL isBloodFull = (self.blood == 4);
        BOOL isAttackEnable = NO;
        if (self.isAttackEnableBlock) {
            isAttackEnable = self.isAttackEnableBlock(self);
        }
        
        NSDictionary *dict = @{@"isBloodFull":@(isBloodFull),
                               @"isAttackEnable":@(isAttackEnable)};
        
        [view enterMainStage:dict];
    }else {
        GameCardModel *card;
        
        if (self.isShaCanBeUsed) {
            card = [self handCardsHasCard:@"Sha"];
        }else if (self.blood < 4) {
            card = [self handCardsHasCard:@"Tao"];
        }
        
        
        if (card) {
            self.useCardBlock(self,card);
        }else {
            if (self.playerOtherEndMainStageBlock) {
                self.playerOtherEndMainStageBlock();
            }
        }
    }
}

- (void)enterEndStage {
    if ([self.playView isKindOfClass:[PlayerSelfView class]]) {
        PlayerSelfView *view = (PlayerSelfView *)self.playView;
        
        [view enterEndStage];
    }
}

- (void)getAttacked {
    if ([self.name isEqualToString:@"玩家"]) {
        NSLog(@"你被杀，请打出一张闪");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PlayerRequiedToUseCard object:@"Shan"];
    }else {
        __block BOOL isShan = NO;
        [self.handCards enumerateObjectsUsingBlock:^(GameCardModel *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.clazz isEqualToString:@"Shan"]) {
                
                isShan = YES;
                NSLog(@"%@出闪",self.name);
                if (self.useCardBlock) {
                    self.useCardBlock(self,obj);
                }
                [self handCardsRemoveCard:obj];
                *stop = YES;
            }
            
        }];
        if (!isShan) {
            NSLog(@"%@掉了1滴血",self.name);
            self.blood--;
        }
    }
}
// 检索手牌
- (GameCardModel *)handCardsHasCard:(NSString *)cardClazz {
    for (GameCardModel *card in self.handCards) {
        if ([card.clazz isEqualToString:cardClazz]) {
            return card;
        }
    }
    return nil;
}

@end

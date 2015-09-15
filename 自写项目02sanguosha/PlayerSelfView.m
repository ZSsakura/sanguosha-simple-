//
//  PlayerSelfView.m
//  自写项目02sanguosha
//
//  Created by Apple on 15/9/7.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "PlayerSelfView.h"
#import "PlayerBaseView.h"
#import "PlayerHandCardView.h"


@interface PlayerSelfView ()

@end

@implementation PlayerSelfView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.userInteractionEnabled = NO;
        // 自身大小固定
        self.size = CGSizeMake(SCREENW, 160);
        
        self.baseView = [[PlayerBaseView alloc] init];
        [self addSubview:self.baseView];
        self.baseView.frameX = self.frameW - self.baseView.frameW;
        
        self.handCardView = [[PlayerHandCardView alloc] init];
        [self addSubview:self.handCardView];
        self.handCardView.frameY = self.frameH - self.handCardView.frameH;
    }
    return self;
}

- (void)setHandCardCanSelectedCount:(NSInteger)count {
    self.handCardView.handCardsCanSelectedCount = count;
    // 开启用户交互
    self.userInteractionEnabled = YES;
}

- (void)enterMainStage:(NSDictionary *)info {
    [self.handCardView enterMainStage:info];
}

- (void)enterEndStage {
    [self.handCardView enterEndStage];
}

- (void)playerSelfViewAddHandCard:(GameCardModel *)card {
    [self.handCardView addCard:card];
}

- (void)playerSelfViewRemoveHandCard:(GameCardModel *)card {
    [self.handCardView removeCard:card];
}

@end

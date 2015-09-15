//
//  PlayerHandCardView.m
//  自写项目02sanguosha
//
//  Created by Apple on 15/9/7.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "PlayerHandCardView.h"
#import "GameCardView.h"
#import "GameCardModel.h"
#import "GameMainViewController.h"

@interface PlayerHandCardView ()

@property (nonatomic,strong) UIButton *quedingBtn;

@property (nonatomic,strong) UIButton *cancelBtn;

@property (nonatomic,strong) NSMutableArray *handCardViews;

@property (nonatomic,assign) GameStage stage;

@property (nonatomic,assign) BOOL requiedToUseCardTag;

@end

@implementation PlayerHandCardView

- (NSMutableArray *)handCardViews {
    if (!_handCardViews) {
        _handCardViews = [NSMutableArray array];
    }
    return _handCardViews;
}

- (NSMutableArray *)handCards {
    if (!_handCards) {
        _handCards = [NSMutableArray array];
    }
    return _handCards;
}

- (NSMutableArray *)selectedHandCards {
    if (!_selectedHandCards) {
        _selectedHandCards = [NSMutableArray array];
    }
    return _selectedHandCards;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 手牌区域大小固定
        self.size = CGSizeMake([UIScreen mainScreen].bounds.size.width - 100, 103);
        self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        
        self.quedingBtn = [[UIButton alloc] init];
        [self.quedingBtn setTitle:@"确定" forState:UIControlStateNormal];
        [self.quedingBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        self.quedingBtn.frame = CGRectMake(self.frameW - 80, 0, 80, 40);
        [self.quedingBtn addTarget:self action:@selector(quedingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.quedingBtn];
        
        self.cancelBtn = [[UIButton alloc] init];
        [self.cancelBtn setTitle:@"弃牌" forState:UIControlStateNormal];
        [self.cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        self.cancelBtn.frame = CGRectMake(self.frameW - 80, self.frameH - 40, 80, 40);
        [self.cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cancelBtn];
        
        self.quedingBtn.enabled = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attackTargetSelected) name:PlayerAttackTargetSelected object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(requiedToUseCardAct:) name:PlayerRequiedToUseCard object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)attackTargetSelected {
    self.quedingBtn.enabled = YES;
}

- (void)requiedToUseCardAct:(NSNotification *)noti {
    self.requiedToUseCardTag = YES;
    NSString *cardClazz = noti.object;
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    
    for (GameCardView *obj in self.handCardViews) {
        if ([obj.card.clazz isEqualToString:cardClazz]) {
            obj.userInteractionEnabled = YES;
        }else {
            obj.userInteractionEnabled = NO;
        }
    }
    self.quedingBtn.enabled = NO;
    self.cancelBtn.enabled = YES;
}

- (void)addCard:(GameCardModel *)card {
    [self.handCards addObject:card];
    GameCardView *cardView = [[GameCardView alloc] init];
    cardView.card = card;
    
    [self addSubview:cardView];
    [self setNeedsLayout];
    [self.handCardViews addObject:cardView];
    __weak typeof(self)wself = self;
    [cardView setCardBeSelected:^(GameCardView *cardView) {
        [wself cardBeSelected:cardView];
    }];
}

- (void)removeCard:(GameCardModel *)card {
    [self.handCards removeObject:card];
    __block NSUInteger indexForRemove;
    [self.handCardViews enumerateObjectsUsingBlock:^(GameCardView *obj, NSUInteger idx, BOOL *stop) {
        if (obj.card == card) {
            indexForRemove = idx;
            *stop = YES;
        }
    }];
    GameCardView *viewForRemove = self.handCardViews[indexForRemove];
    [self.handCardViews removeObject:viewForRemove];
    [viewForRemove removeFromSuperview];
}

- (void)cardBeSelected:(GameCardView *)cardView {
    if ([self.selectedHandCards containsObject:cardView]) {
        [self.selectedHandCards removeObject:cardView];
    }else {
        if (self.selectedHandCards.count == self.handCardsCanSelectedCount) {
            GameCardView *view = self.selectedHandCards[0];
            [view touchesBegan:nil withEvent:nil];
        }
        [self.selectedHandCards addObject:cardView];
    }
    if (self.selectedHandCards.count > 0) {
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    }else if (self.stage == GameStageMain){
        [self.cancelBtn setTitle:@"弃牌" forState:UIControlStateNormal];
    }
    if (self.stage == GameStageMain && self.selectedHandCards.count > 0) {
        GameCardModel *card = [self.selectedHandCards.lastObject card];
        // 主要阶段的点击手牌逻辑
        if ([card.clazz isEqualToString:@"Sha"]||[card.clazz isEqualToString:@"HuoSha"]||[card.clazz isEqualToString:@"LeiSha"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PlayerReadyToAttack object:card];
        }
    }else if (self.stage == GameStageEnd && self.selectedHandCards.count > 0) {
        self.quedingBtn.enabled = YES;
        self.cancelBtn.enabled = YES;
    }else if (self.requiedToUseCardTag && self.selectedHandCards.count == 0) {
        self.quedingBtn.enabled = NO;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSInteger count = self.handCardViews.count;
    
    for (int i = 0; i < count; i++) {
        GameCardView *view = self.handCardViews[i];
        
        view.frameX = i * view.frameW;
    }
    
}

- (void)quedingBtnClick:(UIButton *)sender {
    NSLog(@"确定按钮点击");
    
    NSMutableArray *cards = [NSMutableArray array];
    [self.selectedHandCards enumerateObjectsUsingBlock:^(GameCardView *obj, NSUInteger idx, BOOL *stop) {
        [cards addObject:obj.card];
    }];
    [self.selectedHandCards enumerateObjectsUsingBlock:^(GameCardView *obj, NSUInteger idx, BOOL *stop) {
        [obj touchesBegan:nil withEvent:nil];
    }];
    [self.selectedHandCards removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HandCardViewQuedingBtnClick object:cards];
}

- (void)cancelBtnClick:(UIButton *)sender {
    
    NSString *cancelBtnTitle = sender.titleLabel.text;
    
    NSArray *tempArray = [self.selectedHandCards mutableCopy];
    
    [tempArray enumerateObjectsUsingBlock:^(GameCardView *obj, NSUInteger idx, BOOL *stop) {
        [obj touchesBegan:nil withEvent:nil];
    }];
    
    [self.selectedHandCards removeAllObjects];
//    if (self.stage == GameStageMain) {
    [[NSNotificationCenter defaultCenter] postNotificationName:HandCardViewCancelBtnClick object:cancelBtnTitle];
//    }
}

- (void)enterMainStage:(NSDictionary *)info {
    [self.handCardViews enumerateObjectsUsingBlock:^(GameCardView *obj, NSUInteger idx, BOOL *stop) {
        GameCardModel *card = obj.card;
        if ([card.clazz isEqualToString:@"Shan"]) {
            obj.userInteractionEnabled = NO;
        }else if ([card.clazz isEqualToString:@"Tao"]) {
            obj.userInteractionEnabled = ![info[@"isBloodFull"] boolValue];
        }else if ([card.clazz isEqualToString:@"Sha"]||[card.clazz isEqualToString:@"HuoSha"]||[card.clazz isEqualToString:@"LeiSha"]) {
            obj.userInteractionEnabled = [info[@"isAttackEnable"] boolValue];
        }
    }];
    self.stage = GameStageMain;
    [self.cancelBtn setTitle:@"弃牌" forState:UIControlStateNormal];
}

- (void)enterEndStage {
    [self.handCardViews enumerateObjectsUsingBlock:^(GameCardView *obj, NSUInteger idx, BOOL *stop) {
        obj.userInteractionEnabled = YES;
    }];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    self.cancelBtn.enabled = NO;
    self.quedingBtn.enabled = NO;
    self.stage = GameStageEnd;
}

@end

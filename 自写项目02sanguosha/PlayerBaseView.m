//
//  PlayerBaseView.m
//  自写项目02sanguosha
//
//  Created by Apple on 15/9/7.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "PlayerBaseView.h"

@interface PlayerBaseView ()

@property (nonatomic,strong) UILabel *handCardsLabel;

@property (nonatomic,strong) UILabel *weaponLabel;

@property (nonatomic,strong) UILabel *defenceLabel;

@property (nonatomic,strong) UILabel *defenceHourseLabel;

@property (nonatomic,strong) UILabel *attackHourseLabel;

@end

@implementation PlayerBaseView

- (NSMutableDictionary *)equipmentCards {
    if (!_equipmentCards) {
        _equipmentCards = [NSMutableDictionary dictionary];
        
        _equipmentCards[@"weapon"] = nil;
        _equipmentCards[@"defence"] = nil;
        _equipmentCards[@"+1hourse"] = nil;
        _equipmentCards[@"-1hourse"] = nil;
        
    }
    return _equipmentCards;
}

- (void)setPlayerName:(NSString *)playerName {
    _playerName = playerName;
    self.handCardsLabel.text = [NSString stringWithFormat:@"%@血量%d手牌%ld",playerName,self.blood,self.handCardsCount];
}

- (void)setBlood:(int)blood {
    _blood = blood;
    self.handCardsLabel.text = [NSString stringWithFormat:@"%@血量%d手牌%ld",self.playerName,blood,self.handCardsCount];
}

- (void)setHandCardsCount:(NSInteger)handCardsCount {
    _handCardsCount = handCardsCount;
    self.handCardsLabel.text = [NSString stringWithFormat:@"%@血量%d手牌%ld",self.playerName,self.blood,handCardsCount];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.size = CGSizeMake(100, 160);
        self.backgroundColor = [UIColor redColor];
        
        self.handCardsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        self.handCardsLabel.textColor = [UIColor blackColor];
        self.handCardsLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.handCardsLabel];
        
        self.weaponLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 100, 40)];
        self.weaponLabel.textColor = [UIColor blackColor];
        [self addSubview:self.weaponLabel];
        
        self.defenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 100, 40)];
        self.defenceLabel.textColor = [UIColor blackColor];
        [self addSubview:self.defenceLabel];
        
        self.defenceHourseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, 50, 40)];
        self.defenceHourseLabel.textColor = [UIColor blackColor];
        [self addSubview:self.defenceHourseLabel];
        
        self.attackHourseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 50, 40)];
        self.attackHourseLabel.textColor = [UIColor blackColor];
        [self addSubview:self.attackHourseLabel];
    }
    return self;
}

- (void)addEquipment:(GameCardModel *)card {
    // 判断牌属性，添加装备牌，改变各个label的值
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayerSelected object:self.playerName];
}

@end

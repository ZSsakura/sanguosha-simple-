//
//  GameCardView.m
//  自写项目02sanguosha
//
//  Created by Apple on 15/9/5.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "GameCardView.h"

#import "GameCardModel.h"

@interface GameCardView ()
// 背景
@property (nonatomic,strong) UIImageView *bgimageView;
// 花色
@property (nonatomic,strong) UIImageView *colorView;

@property (nonatomic,strong) UIImageView *pokerNumView;

@property (nonatomic,assign) BOOL isSelected;

@property (nonatomic,strong) UIView *coverView;

@end

@implementation GameCardView

- (void)setCard:(GameCardModel *)card {
    _card = card;
    // 通过数据设置具体的图片
    self.bgimageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"card%@",card.imageID]];
    
    self.colorView.image = [UIImage imageNamed:[NSString stringWithFormat:@"color0%@",card.color]];
    
    NSString *numImageName;
    
    if ([card.color intValue] == 0 || [card.color intValue] == 1) {
        numImageName = [NSString stringWithFormat:@"pokerred%02d",[card.number intValue]];
    }else {
        numImageName = [NSString stringWithFormat:@"pokerblack%02d",[card.number intValue]];
    }
    self.pokerNumView.image = [UIImage imageNamed:numImageName];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.size = CGSizeMake(73, 103);
        // 所有子控件位置固定，着这里直接设置
        self.bgimageView = [[UIImageView alloc] init];
        [self addSubview:self.bgimageView];
        self.bgimageView.frame = self.bounds;
        
        self.colorView = [[UIImageView alloc] init];
        [self.bgimageView addSubview:self.colorView];
        self.colorView.frame = CGRectMake(0, 0, 16, 16);
        
        self.pokerNumView = [[UIImageView alloc] init];
        [self.bgimageView addSubview:self.pokerNumView];
        self.pokerNumView.frame = CGRectMake(0, 16, 16, 19);
    }
    
    
    return self;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:self.bounds];
        _coverView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    }
    return _coverView;
}

/**
 *  当卡片不可点时，为卡片添加一层灰色蒙版。可点时删除
 */
- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    
    [super setUserInteractionEnabled:userInteractionEnabled];
    
    if (!userInteractionEnabled) {
        [self addSubview:self.coverView];
    }else {
        [self.coverView removeFromSuperview];
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.cardBeSelected) {
        self.cardBeSelected(self);
    }
    
    if (!self.isSelected) {
        // 牌未选中时点击
        self.bgimageView.frameY = self.bgimageView.frameY - 10;
    }else {
        // 选中点击恢复
        self.bgimageView.frameY = 0;
    }
    self.isSelected = !self.isSelected;
}

@end

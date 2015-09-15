//
//  GameCardView.h
//  自写项目02sanguosha
//
//  Created by Apple on 15/9/5.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameCardModel;
@interface GameCardView : UIView

@property (nonatomic,strong) GameCardModel *card;

@property (nonatomic,copy) void(^cardBeSelected)(GameCardView *cardView);

@end

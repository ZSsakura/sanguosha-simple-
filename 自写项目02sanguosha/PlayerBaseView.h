//
//  PlayerBaseView.h
//  自写项目02sanguosha
//
//  Created by Apple on 15/9/7.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameCardModel;

@interface PlayerBaseView : UIView

@property (nonatomic,copy) NSString *playerName;
@property (nonatomic,assign) NSInteger handCardsCount;
@property (nonatomic,assign) int blood;

@property (nonatomic,strong) NSMutableDictionary *equipmentCards;

- (void)addEquipment:(GameCardModel *)card;

@end

//
//  GameMainViewController.h
//  自写项目02sanguosha
//
//  Created by Apple on 15/9/5.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    GameStageJudge = 1,
    GameStagePostCard,
    GameStageMain,
    GameStageEnd,
} GameStage;

@interface GameMainViewController : UIViewController

@end

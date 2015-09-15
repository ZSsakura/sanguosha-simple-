//
//  GameMainViewController.m
//  自写项目02sanguosha
//
//  Created by Apple on 15/9/5.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "GameMainViewController.h"
#import "GameCardModel.h"
#import "GameCardView.h"
#import "PlayerSelfView.h"
#import "PlayerBaseView.h"
#import "Player.h"
#import <math.h>



@interface GameMainViewController ()<NSXMLParserDelegate,UIAlertViewDelegate>
// 武将数组
@property (nonatomic,strong) NSArray *allCharacters;
// 牌堆
@property (nonatomic,strong) NSMutableArray *gameCardsUseable;
// 弃牌堆
@property (nonatomic,strong) NSMutableArray *gameCardsCantUse;

// 显示加载中...页面
@property (nonatomic,strong) UIView *loadingView;

@property (nonatomic,strong) Player *playerSelf;
@property (nonatomic,strong) PlayerSelfView *viewSelf;

@property (nonatomic,strong) Player *playerOther;
@property (nonatomic,strong) PlayerBaseView *viewOther;

@property (nonatomic,strong) NSMutableArray *players;
// 当前正在进行游戏的玩家
@property (nonatomic,weak) Player *currentPlayer;
// 游戏阶段
@property (nonatomic,assign) GameStage currentStage;

#pragma mark - 游戏逻辑
// 正在选择角色(对角色view的点击做出响应)
@property (nonatomic,assign) BOOL selectingPlayer;

@property (nonatomic,weak) Player *selectedPlayer;
// 标志正在进行濒死判定
@property (nonatomic,assign) BOOL dyingJudge;
// 濒死的角色
@property (nonatomic,weak) Player *dyingPlayer;
// 正在执行角色被“杀”判定
@property (nonatomic,assign) BOOL beAttackJudge;

@end

@implementation GameMainViewController

- (NSMutableArray *)gameCardsUseable {
    if (!_gameCardsUseable) {
        _gameCardsUseable = [NSMutableArray array];
    }
    return _gameCardsUseable;
}

- (NSMutableArray *)gameCardsCantUse {
    if (!_gameCardsCantUse) {
        _gameCardsCantUse = [NSMutableArray array];
    }
    return _gameCardsCantUse;
}

- (UIView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIView alloc] init];
        _loadingView.frame = self.view.bounds;
        _loadingView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = @"加载中...";
        [label sizeToFit];
        label.center = CGPointMake(_loadingView.frameW * 0.5, _loadingView.frameH * 0.5);
        
        [_loadingView addSubview:label];
    }
    return _loadingView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *bgImageView = [[UIImageView alloc] init];
    
    bgImageView.image = [UIImage imageNamed:@"contentBg"];
    bgImageView.frame = self.view.frame;
    
    [self.view addSubview:bgImageView];
    
    // 显示加载中页面，解析XML(赋值牌堆)，配置游戏设定。解析完成后开始游戏
    
    [self loadingView];
    self.loadingView.alpha = 1.0;
    
    NSString *cardsPath = [[NSBundle mainBundle] pathForResource:@"Cards.xml" ofType:nil];
    NSData *data = [[NSData alloc] initWithContentsOfFile:cardsPath];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    
    [parser parse];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readyToAttack:) name:PlayerReadyToAttack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedPlayer:) name:PlayerSelected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handCardViewQuedingBtnClick:) name:HandCardViewQuedingBtnClick object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handCardViewCancelBtnClick:) name:HandCardViewCancelBtnClick object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDyingAct:) name:PlayerIsDying object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 解析卡牌
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
//    NSLog(@"解析元素名称%@,元素属性%@",elementName,attributeDict);
    
    if ([elementName isEqualToString:@"Card"] && [attributeDict[@"CardID"] intValue] < 500) {
        GameCardModel *card = [GameCardModel gameCardModelWithDict:attributeDict];
        
        [self.gameCardsUseable addObject:card];
    }
}

// 玩家点击杀的消息响应
- (void)readyToAttack:(NSNotification *)noti {
//    GameCardModel *card = noti.object;
    NSLog(@"请选择杀的角色");
    self.selectingPlayer = YES;
}

// 玩家选择了角色的消息响应
- (void)selectedPlayer:(NSNotification *)noti {
    
    if (!self.selectingPlayer) {
        return;
    }
    
    __block Player *player;
    [self.players enumerateObjectsUsingBlock:^(Player *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.name isEqualToString:noti.object]) {
            player = obj;
            *stop = YES;
        }
    }];
    if (player == self.playerSelf) {
        NSLog(@"选择了非法的角色");
    }else {
        int attrDis = 0;
        int touchDis = 1;
        int positionDis = abs(player.position - self.playerSelf.position);
        if (attrDis + touchDis >= positionDis) {
            self.selectedPlayer = player;
            [[NSNotificationCenter defaultCenter] postNotificationName:PlayerAttackTargetSelected object:nil];
        }else {
            NSLog(@"距离不够");
        }
    }
}

// 玩家在手牌view点击了确定按钮的消息响应
- (void)handCardViewQuedingBtnClick:(NSNotification *)noti {
    
    if (self.dyingJudge) {
        GameCardModel *card = [noti.object lastObject];
        [self.dyingPlayer handCardsRemoveCard:card];
        [self throwCard:card];
        
        self.dyingPlayer.blood++;
        self.dyingJudge = NO;
        self.dyingPlayer = nil;
        [self.currentPlayer enterMainStage];
        return;
    }
    
    if (self.beAttackJudge) {
        GameCardModel *card = [noti.object lastObject];
        NSLog(@"你使用了一张闪");
        self.beAttackJudge = NO;
        [self.playerSelf handCardsRemoveCard:card];
        [self throwCard:card];
        
        [self.currentPlayer enterMainStage];
        return;
    }
    
    if (self.currentPlayer == self.playerSelf && self.currentStage == GameStageMain) {
        
        GameCardModel *card = [noti.object lastObject];
        if ([card.clazz isEqualToString:@"Sha"]||[card.clazz isEqualToString:@"HuoSha"]||[card.clazz isEqualToString:@"LeiSha"]) {
            NSLog(@"%@对%@使用了一张杀",self.playerSelf.name,self.selectedPlayer.name);
            self.currentPlayer.isShaCanBeUsed = NO; // 加入武器牌等等，会有更复杂的逻辑判断
            [self.selectedPlayer getAttacked];
        }else if ([card.clazz isEqualToString:@"Tao"]) {
            self.currentPlayer.blood++;
        }
        self.selectingPlayer = NO;
        self.selectedPlayer = nil;
        [self.playerSelf handCardsRemoveCard:card];
        [self throwCard:card];
        if (!self.dyingJudge) {
            [self.playerSelf enterMainStage];
        }
    }else if (self.currentPlayer == self.playerSelf && self.currentStage == GameStageEnd) {
        NSArray *cards = noti.object;
        [cards enumerateObjectsUsingBlock:^(GameCardModel *obj, NSUInteger idx, BOOL *stop) {
            [self.playerSelf handCardsRemoveCard:obj];
            [self throwCard:obj];
        }];
        NSLog(@"弃掉了%ld张牌",cards.count);
        [self endStageAct];
    }
}
// 玩家在手牌view点击取消按钮的消息响应
- (void)handCardViewCancelBtnClick:(NSNotification *)noti {
    // 濒死判定优先
    if (self.dyingJudge) {
        // 角色死亡
        [self playerDead:self.dyingPlayer];
    }
    
    if (self.beAttackJudge) {
        NSLog(@"你受到一点伤害");
        self.playerSelf.blood--;
        self.beAttackJudge = NO;
        if (!self.dyingJudge) {
            [self.currentPlayer enterMainStage];
        }
        return;
    }
    
    
    if (self.currentPlayer == self.playerSelf && self.currentStage == GameStageMain) {
        
        if ([noti.object isEqualToString:@"取消"]) {
            self.selectedPlayer = nil;
            self.selectingPlayer = NO;
        }else {
            [self nextStage];
        }
    }
}
// 濒死状态结算，事件响应
- (void)playerDyingAct:(NSNotification *)noti {
    Player *dyingPlayer = noti.object;
    
    if (dyingPlayer != self.playerSelf) {
        GameCardModel *card = [dyingPlayer handCardsHasCard:@"Tao"];
        if (card) {
            // 手中有桃，则使用
            [dyingPlayer handCardsRemoveCard:card];
            [self throwCard:card];
            dyingPlayer.blood++;
            NSLog(@"%@使用了一张桃",dyingPlayer.name);
        }else {
            // 手中没有桃，请求其他人出桃
            NSLog(@"%@濒死，请为他使用桃",dyingPlayer.name);
            self.dyingJudge = YES;
            self.dyingPlayer = dyingPlayer;
            [self.viewSelf setHandCardCanSelectedCount:1];
            [[NSNotificationCenter defaultCenter] postNotificationName:PlayerRequiedToUseCard object:@"Tao"];
        }
    }
}
// 非玩家角色使用卡片，回调方法
- (void)playerOtherUseCard:(GameCardModel *)card {
    if ([card.clazz isEqualToString:@"Sha"]) {
        [self.playerOther handCardsRemoveCard:card];
        [self throwCard:card];
        self.playerOther.isShaCanBeUsed = NO;
        self.beAttackJudge = YES;
        [self.playerSelf getAttacked];
    }else if ([card.clazz isEqualToString:@"Tao"]) {
        [self.playerOther handCardsRemoveCard:card];
        [self throwCard:card];
        self.playerOther.blood++;
        [self.playerOther enterMainStage];
    }
}

// 在这里开始游戏
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
//    NSLog(@"元素解析完成%@",elementName);
    if ([elementName isEqualToString:@"Cards"]) {
        NSLog(@"卡片张数%ld",self.gameCardsUseable.count);
        
        self.loadingView.alpha = 0.0;
        
        [self gameStart];
    }
}
// 洗牌(乱序)
- (void)shuffleCards:(NSMutableArray *)cards {
    
    [cards sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if (arc4random_uniform(2)) {
            return NSOrderedAscending;
        }else
            return NSOrderedDescending;
    }];
    
}
// 抽牌
- (GameCardModel *)getACard {
    if (self.gameCardsUseable.count == 0) {
        // 牌堆空时，重新洗牌，刷新牌堆和弃牌堆
        [self shuffleCards:self.gameCardsCantUse];
        self.gameCardsUseable = self.gameCardsCantUse;
        self.gameCardsCantUse = nil;
    }
    
    GameCardModel *card = [self.gameCardsUseable firstObject];
    [self.gameCardsUseable removeObject:card];
    
    return card;
}
// 发牌
- (void)postCard:(GameCardModel *)card ToPlayer:(Player *)player {
    [player handCardsAddCard:card];
}

// 弃牌
- (void)throwCard:(GameCardModel *)card {
    [self.gameCardsCantUse addObject:card];
}

// 角色死亡
- (void)playerDead:(Player *)player {
    
    [self.players removeObject:player];
    NSString *winName = [[self.players lastObject] name];
    NSString *winMes = [NSString stringWithFormat:@"胜利者是%@",winName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"游戏结束" message:winMes delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)gameStart {
//    GameCardModel *model = [self.gameCardsUseable firstObject];
//    GameCardView *view = [[GameCardView alloc] init];
//    
//    view.card = model;
//    
//    [self.view addSubview:view];
    PlayerSelfView *viewSelf = [[PlayerSelfView alloc] init];
    self.viewSelf = viewSelf;
    [self.view addSubview:viewSelf];
    viewSelf.frameY = self.view.frameH - viewSelf.frameH;
    
    Player *playerSelf = [[Player alloc] init];
    playerSelf.playView = viewSelf;// 游戏角色与视图显示关联
    playerSelf.name = @"玩家";
    playerSelf.blood = 4;
    self.playerSelf = playerSelf;
    __weak typeof(self)wself = self;
    [playerSelf setIsAttackEnableBlock:^BOOL(Player *player) {
        return [wself isAttackEnableJudge:player];
    }];
    
    PlayerBaseView *viewOther = [[PlayerBaseView alloc] init];
    self.viewOther = viewOther;
    [self.view addSubview:viewOther];
    viewOther.centerX = self.view.frameW * 0.5;
    
    Player *playerOther = [[Player alloc] init];
    playerOther.playView = viewOther;// 游戏角色与视图显示关联
    playerOther.name = @"电脑1";
    playerOther.blood = 4;
    self.playerOther = playerOther;
    [playerOther setIsAttackEnableBlock:^BOOL(Player *player) {
        return [wself isAttackEnableJudge:player];
    }];
    [playerOther setUseCardBlock:^(Player *player, GameCardModel *card) {
        [self playerOtherUseCard:card];
    }];
    [playerOther setPlayerOtherEndMainStageBlock:^{
        [self nextStage];
    }];
    
    self.players = [NSMutableArray array];
    [self.players addObject:self.playerSelf];
    [self.players addObject:self.playerOther];
    
    [self shuffleCards:self.gameCardsUseable];
    
    for (int i = 0; i < 4; i++) {
        [self postCard:[self getACard] ToPlayer:playerSelf];
        
        [self postCard:[self getACard] ToPlayer:playerOther];
    }
    self.currentPlayer = self.playerSelf;
    self.currentStage = GameStageJudge;
}

- (void)setCurrentStage:(GameStage)currentStage {
    _currentStage = currentStage;
    switch (currentStage) {
        case GameStageJudge:
            [self judgeStageAct];
            break;
        case GameStagePostCard:
            [self postCardStageAct];
            break;
        case GameStageMain:
            [self mainStageAct];
            break;
        case GameStageEnd:
            [self endStageAct];
            break;
            
        default:
            break;
    }
}

- (void)nextStage {
    GameStage stage = self.currentStage;
    stage++;
    if (stage == 5) {
        // 阶段到底，重置的时候切换角色
        stage = GameStageJudge;
        [self nextPlayer];
    }
    self.currentStage = stage;// 调用set方法,自动调用阶段逻辑
}

- (void)nextPlayer {
    NSUInteger index = [self.players indexOfObject:self.currentPlayer];
    index++;
    if (index == self.players.count) {
        index = 0;
    }
    self.currentPlayer = self.players[index];
}

- (void)judgeStageAct {
    NSLog(@"判定阶段");
    [self nextStage];
}

- (void)postCardStageAct {
    NSLog(@"抽牌阶段");
    // 抽两张牌
    [self postCard:[self getACard] ToPlayer:self.currentPlayer];
    [self postCard:[self getACard] ToPlayer:self.currentPlayer];
    [self nextStage];
}

- (void)mainStageAct {
    if (self.currentPlayer == self.playerOther) {
        self.playerOther.isShaCanBeUsed = YES;
        [self.playerOther enterMainStage];
    }else {
        // 用户执行操作
        self.playerSelf.isShaCanBeUsed = YES;
        [self.viewSelf setHandCardCanSelectedCount:1];
        [self.playerSelf enterMainStage];
    }
}

- (void)endStageAct {
    NSInteger diff = self.currentPlayer.handCards.count - self.currentPlayer.blood;
    if (self.currentPlayer == self.playerOther) {
        while (diff > 0) {
            // 手牌数大于血量，弃牌(从手牌中移除,放入弃牌堆)
            diff--;
            GameCardModel *card = self.playerOther.handCards[0];
            [self.playerOther handCardsRemoveCard:card];
            [self.gameCardsCantUse addObject:card];
            NSLog(@"%@弃掉手牌%@",self.playerOther.name,card.name);
        }
        [self nextStage];
    }else {
        // 用户弃牌
        if (diff > 0) {
            NSLog(@"请弃掉%ld张牌",diff);
            [self.viewSelf setHandCardCanSelectedCount:diff];
            [self.playerSelf enterEndStage];
        }else {
            [self nextStage];
        }
    }
}

- (BOOL)isAttackEnableJudge:(Player *)player {
    __block BOOL temp = NO;
    [self.players enumerateObjectsUsingBlock:^(Player *obj, NSUInteger idx, BOOL *stop) {
        if (obj != player) {
            int attrDis = 0;
            int touchDis = 1;
            int positionDis = abs(player.position - obj.position);
            if (attrDis + touchDis >= positionDis) {
                temp = YES;
                *stop = YES;
            }
        }
    }];
    return temp && player.isShaCanBeUsed;
}

@end

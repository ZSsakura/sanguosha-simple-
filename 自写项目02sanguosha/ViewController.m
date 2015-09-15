//
//  ViewController.m
//  自写项目02sanguosha
//
//  Created by Apple on 15/9/5.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "ViewController.h"
#import "GameMainViewController.h"

@interface ViewController ()

@property (nonatomic,strong) UIButton *startBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.startBtn = [[UIButton alloc] init];
    
    self.startBtn.size = CGSizeMake(100, 44);
    
    self.startBtn.center = self.view.center;
    
    self.startBtn.backgroundColor = [UIColor redColor];
    
    [self.startBtn setTitle:@"单机1V1" forState:UIControlStateNormal];
    
    [self.startBtn addTarget:self action:@selector(startBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.startBtn];
}

- (void)startBtnClick {
    GameMainViewController *gameVc = [[GameMainViewController alloc] init];
    
    [self presentViewController:gameVc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

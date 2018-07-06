//
//  ViewController.m
//  GPU_ImageProcessingIphone
//
//  Created by 汤义 on 2018/7/5.
//  Copyright © 2018年 汤义. All rights reserved.
//

#import "ViewController.h"
#import "TYSkinCareViewController.h"
#import "TYTestPerformanceViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initButView];
}

- (void)initButView{
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame = CGRectMake(10, 64, 100, 30);
    but.backgroundColor = [UIColor redColor];
    [but setTitle:@"美颜" forState:UIControlStateNormal];
    [but addTarget:self action:@selector(selectorBut) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but];
    
    UIButton *but1 = [UIButton buttonWithType:UIButtonTypeCustom];
    but1.frame = CGRectMake(10, 100, 100, 30);
    but1.backgroundColor = [UIColor redColor];
    [but1 setTitle:@"测试性能" forState:UIControlStateNormal];
    [but1 addTarget:self action:@selector(selectorBut1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but1];
}

- (void)selectorBut {
    TYSkinCareViewController *vc = [[TYSkinCareViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)selectorBut1 {
    TYTestPerformanceViewController *vc = [[TYTestPerformanceViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

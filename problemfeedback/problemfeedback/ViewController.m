//
//  ViewController.m
//  problemfeedback
//
//  Created by hqs on 16/3/4.
//  Copyright © 2016年 hqs. All rights reserved.
//

#import "ViewController.h"

#import "ProblemFeedbackController.h"

@interface ViewController()<ProblemFeedbackControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(20, 90, 100, 40)];
    [button setTitle:@"问题反馈" forState:UIControlStateNormal];
    button.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.6];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}


- (void)buttonClick{
    ProblemFeedbackController *pVC = [[ProblemFeedbackController alloc] init];
    pVC.problemFeedbackDelegate = self;
    pVC.hideTitle = NO;
    pVC.title = @"问题反馈";
    
    [self presentViewController:pVC animated:YES completion:nil];
}


- (void)proglemFeedbackController:(ProblemFeedbackController *)problemFeedbackController didSubmitInfo:(NSDictionary *)info{
    NSLog(@"info =  %@",info);
    
    [problemFeedbackController dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

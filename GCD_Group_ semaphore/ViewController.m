//
//  ViewController.m
//  GCD_Group_ semaphore
//
//  Created by 胡海峰 on 2017/8/29.
//  Copyright © 2017年 胡海峰. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //[self groupMethod];
    
    //[self semaphoreMethod];
    
    [self groupSemaphoreMethod];
}


- (void)groupMethod
{
    //创建一个组
    dispatch_group_t group = dispatch_group_create();
    for (int i = 0; i <9; i++)
    {//模仿多个网络请求
        
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //异步网络请求
            
            int x = arc4random() % 5;
            //模拟网络请求快慢不确定的情况
            sleep(x);
            NSLog(@"group 请求成功OR请求失败 %d!",i);
            
            dispatch_group_leave(group);
        });
    }
    NSLog(@"group开始 网络请求!");
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //网络请求完毕 回到主线程更新UI 或者做些其它的操作
        NSLog(@"group所有请求完毕!!!");
    });
}

- (void)semaphoreMethod
{
    //创建一个信号量 数值为1
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    for (int i = 0; i<9; i++)
    {//模仿多个网络请求
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            //执行dispatch_semaphore_wait 信号量数值 -1.
            //当i为0此时的信号量数值为0, 继续执行wait函数下面的语句.
            //当i为1此时的信号量数值为-1, 阻塞当前线程 阻塞时长为DISPATCH_TIME_FOREVER, 不执行wait函数下面的语句.
            //只有等到执行i为0 的 dispatch_semaphore_signal 方法执行, 信号量数值+1 为0, 唤醒 继续执行wait函数下面的语句.
            //以此类推循环.
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            //异步网络请求
            int x = arc4random() % 5;
            //模拟网络请求快慢不确定的情况
            sleep(x);
            
            //信号量数值+1
            dispatch_semaphore_signal(semaphore);
            
            NSLog(@"semaphore 请求成功OR请求失败 %d!",i);
            
        });
    }
    NSLog(@"semaphore开始 网络请求!");
}

- (void)groupSemaphoreMethod
{
    dispatch_group_t group = dispatch_group_create();
    //创建一个信号量 数值为1
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    for (int i = 0; i<9; i++)
    {//模仿多个网络请求
        dispatch_group_async(group,dispatch_get_global_queue(0, 0), ^{
            
            //执行dispatch_semaphore_wait 信号量数值 -1.
            //当i为0此时的信号量数值为0, 继续执行wait函数下面的语句.
            //当i为1此时的信号量数值为-1, 阻塞当前线程 阻塞时长为DISPATCH_TIME_FOREVER, 不执行wait函数下面的语句.
            //只有等到执行i为0 的 dispatch_semaphore_signal 方法执行, 信号量数值+1 为0, 唤醒 继续执行wait函数下面的语句.
            //以此类推循环.
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            //异步网络请求
            int x = arc4random() % 5;
            //模拟网络请求快慢不确定的情况
            sleep(x);
            
            //信号量数值+1
            dispatch_semaphore_signal(semaphore);
            
            NSLog(@"groupSemaphore 请求成功OR请求失败 %d!",i);
            
        });
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //网络请求完毕 回到主线程更新UI 或者做些其它的操作
        NSLog(@"groupSemaphore所有请求完毕!!!");
    });
    
    NSLog(@"groupSemaphore开始 网络请求!");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

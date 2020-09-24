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

/// 多个异步任务执行完成后通知
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
/// 多个异步任务 同步执行
- (void)semaphoreMethod
{
    /// 创建一个线程"001" 确保之后不要阻塞主线程
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        /// 创建一个信号量 数值为1  信号量可以让线程阻塞等待
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        for (int i = 0; i<9; i++) {
            /// 模仿9个请求任务
            /// 执行dispatch_semaphore_wait 信号量数值 -1.
            /// 当i为0此时的信号量数值为0, 当此时的信号量大于等于0继续执行wait函数下面的语句.
            /// 当i为1此时的信号量数值为-1, 阻塞当前线程 阻塞时长为DISPATCH_TIME_FOREVER, 不执行wait函数下面的语句.
            /// 只有等到执行i为0 的 dispatch_semaphore_signal 方法执行, 信号量数值+1 为0, 唤醒 继续执行wait函数下面的语句.
            /// 以此类推循环.
            NSLog(@"当前线程:%@",[NSThread currentThread]);
            
            /// ******这是一个网络请求开始******
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                /// 模拟异步网络请求
                int x = arc4random() % 2;
                /// 模拟网络请求快慢
                sleep(x);
                NSLog(@"执行任务代号:%d",i);
                /// 任务结束 信号量数值+1 解放线程"001" 阻塞
                dispatch_semaphore_signal(semaphore);
            });
            /// ******这是一个网络请求结束******

            /// 信号量减1 变为负数 当前线程"001" 阻塞
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    });
}
/// 多个异步任务 同步执行 执行完成通知
- (void)groupSemaphoreMethod
{
    /// 创建一个线程"001" 确保之后不要阻塞主线程
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        dispatch_group_t group = dispatch_group_create();
        
        /// 创建一个信号量 数值为0
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        for (int i = 0; i<9; i++)
        {
            /// 模仿9个请求任务
            dispatch_group_async(group,dispatch_get_global_queue(0, 0), ^{
//                /// 异步网络请求
//                int x = arc4random() % 2;
//                /// 模拟网络请求快慢不确定的情况
//                sleep(x);

                NSLog(@"执行任务:%d 线程:%@",i,[NSThread currentThread]);
                /// 任务结束 信号量数值+1 解放线程"001" 阻塞
                dispatch_semaphore_signal(semaphore);
            });
            
            /// 信号量减1 变为负数 当前线程"001" 阻塞
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            //NSLog(@"阻塞线程:%@",[NSThread currentThread]);
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            /// 网络请求完毕 回到主线程更新UI 或者做些其它的操作
            NSLog(@"所有任务执行完毕!!!");
        });
    });
}

- (void)serialMethod {
    dispatch_queue_t queue = dispatch_queue_create("serial",DISPATCH_QUEUE_SERIAL);
    ///在串行队列中 执行第一个异步任务
    dispatch_async(queue, ^{
        NSLog(@"1---%@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:5];
        NSLog(@"xxxxxxxxxxxxxx");
    });
    ///在串行队列中 执行第二个异步任务
    dispatch_async(queue, ^{
        NSLog(@"2---%@", [NSThread currentThread]);
    });
    ///在串行队列中 执行第三个异步任务
    dispatch_async(queue, ^{
        NSLog(@"3---%@", [NSThread currentThread]);
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

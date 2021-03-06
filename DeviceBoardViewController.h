//
//  DeviceBoardViewController.h
//  HaierOven
//
//  Created by dongl on 14/12/23.
//  Copyright (c) 2014年 edaysoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"

typedef NS_ENUM(NSInteger, DeviceBoardStatus)
{
    /**
     *  运行模式
     */
    DeviceBoardStatusWorking,
    /**
     *  关机模式
     */
    DeviceBoardStatusClosed,
    /**
     *  选择烘焙模式
     */
    DeviceBoardStatusSelectMode,
    /**
     *  开机模式
     */
    DeviceBoardStatusOpened,
    /**
     *  停止运行
     */
    DeviceBoardStatusStop,
    /**
     *  预约状态
     */
    DeviceBoardStatusOrdering,
    /**
     *  预热状态
     */
    DeviceBoardStatusPreheating

};


@interface DeviceBoardViewController : BaseTableViewController

@property (nonatomic) DeviceBoardStatus deviceBoardStatus;
/**
 *  本地当前烤箱对象，Model可根据此对象构建uSDKDevice对象，从而控制烤箱
 */
@property (strong, nonatomic) LocalOven* currentOven;

/**
 *  点击开始烹饪的烤箱设置模式，烤箱根据此模式开始工作
 */
@property (strong, nonatomic) CookbookOven* startBakeOvenInfo;


@end

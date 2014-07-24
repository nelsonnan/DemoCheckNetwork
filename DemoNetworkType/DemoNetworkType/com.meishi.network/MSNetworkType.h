//
//  MSNetworkType.h
//  DemoNetworkType
//
//  Created by Meishi on 14-7-24.
//  Copyright (c) 2014年 Kangbo. All rights reserved.
//

/**
 *  @brief  判断网络类型
 *  1，使用priate api 在信号栏不隐藏的情况下 通过信号栏的网络连接图标（没测试）
 *  2，使用苹果官方提供的网络判断类，需要修改区分2G 3G
 */

#import <Foundation/Foundation.h>
#import "Reachability.h"
/**
 *  网络类型enum
 */
typedef enum {
    /** 无网络类型 */
    NETWORK_TYPE_NONE = 0,
    /** 2G网络 */
    NETWORK_TYPE_2G,
    /** 3G网络 */
    NETWORK_TYPE_3G,
    /** 4G网络 */
    NETWORK_TYPE_4G,
    /** 5G网络 */
    NETWORK_TYPE_5G,//5G目前为猜测结果
    /** wifi网络 */
    NETWORK_TYPE_WIFI,
    /** WWAN */
    NETWORK_TYPE_WWAN,
}NetworkType;

@interface MSNetworkType : NSObject

/**
 *  @brief  判断网络连接类型，//testk
 *
 */
@property(nonatomic, assign) NetworkType networkStatus;

+ (instancetype)sharedinstance;

/**
 *  @brief  网络是否连接正常
 *  @return YES NO
 */
- (BOOL)isConnected;
@end

//testk 私有api
#pragma mark - 判断网络类型 priate api

@interface MSNetworkTypeUI : NSObject

/**
 *  @brief  判断网络连接类型 信号栏不隐藏的情况下，通过信号栏的网络连接图标
 *  @return NetworkType 网络类型
 */
+ (NetworkType)getNetworkTypeFromStatusBar;

@end
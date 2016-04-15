//
//  QYHSessionModel.h
//  AfnetWorkingDemo
//
//  Created by quyanhuiqu on 16/4/13.
//  Copyright © 2016年 quyanhuiqu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
typedef enum {
    DownloadStateStart = 0,     /** 下载中 */
    DownloadStateSuspended,     /** 下载暂停 */
    DownloadStateCompleted,     /** 下载完成 */
    DownloadStateFailed         /** 下载失败 */
}DownloadState;
@interface QYHSessionModel : NSObject
/** 下载地址 */
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) void(^progressBlock)(CGFloat progress);
/** 下载状态 */
@property (nonatomic, copy) void(^stateBlock)(DownloadState state);

@property (nonatomic, copy) void(^fileBlock)(NSString *filepath);
@end

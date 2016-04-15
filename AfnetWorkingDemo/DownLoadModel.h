//
//  DownLoadModel.h
//  AfnetWorkingDemo
//
//  Created by quyanhuiqu on 16/4/14.
//  Copyright © 2016年 quyanhuiqu. All rights reserved.
//

#import "JKDBModel.h"
#import <CoreGraphics/CoreGraphics.h>


@interface DownLoadModel : JKDBModel

@property(nonatomic,strong)NSString *urlSting;

@property (nonatomic,assign)CGFloat progress;
//拼接文件路径
@property (nonatomic,strong)NSNumber *numberID;

@end

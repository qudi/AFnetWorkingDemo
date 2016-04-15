//
//  JKDataBase.h
//  JKBaseModel
//  Created by quyanhuiqu on 16/3/16.
//  Copyright © 2016年 Gome. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface JKDBHelper : NSObject

@property (nonatomic, retain, readonly) FMDatabaseQueue *dbQueue;

+ (JKDBHelper *)shareInstance;

+ (NSString *)dbPath;

@end

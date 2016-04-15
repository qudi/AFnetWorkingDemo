//
//  ViewController.m
//  AfnetWorkingDemo
//
//  Created by quyanhuiqu on 16/4/13.
//  Copyright © 2016年 quyanhuiqu. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import <AFNetworking.h>
#import <AFNetworking/AFNetworking.h>
#import "QYHSessionModel.h"
#import "DownLoadModel.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)NSMutableArray *downloadMp4Arr;

/** 创建一个全局 AFURLSessionManager 对象 */
@property (nonatomic, strong)AFURLSessionManager *manager;

/** 存放下载任务的数组 */
@property (nonatomic, strong) NSMutableArray *downloadTaskArray;

/** 保存所有下载相关信息 */
@property (nonatomic, strong) NSMutableDictionary *sessionModels;

@property (nonatomic ,strong)NSMutableDictionary *tasks;

@property (nonatomic ,strong)UITableView *tableview;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _downloadMp4Arr = [NSMutableArray new];
    
//    NSArray *arr = [NSArray arrayWithObjects:@"http://fdfs.xmcdn.com/group13/M01/3D/96/wKgDXVcF9wyTpF9PAH09grSjfDI899.mp3",@"http://pianke.file.alimmdn.com/upload/20160127/71ea74352fcbd6b52f33b88b7eddf652.MP3",@"http://10.125.3.61:80/v1/img/T16aCTB5xT1RCvBVdK_vedio.mp4",@"http://10.125.3.61:80/v1/img/T1DydTByWT1RCvBVdK_vedio.mp4", nil];
//    
//    for(int i = 0;i<arr.count;i++){
//        NSString *str =[arr objectAtIndex:i];
//        DownLoadModel *sessionModel = [[DownLoadModel alloc] init];
//        sessionModel.urlSting = str;
//        sessionModel.numberID = [NSNumber numberWithInt:i+1000];
//        sessionModel.progress = 0.0f;
//        [_downloadMp4Arr addObject:sessionModel];
//    }
//    
//    [DownLoadModel saveObjects:_downloadMp4Arr];
    
    [_downloadMp4Arr addObjectsFromArray:[DownLoadModel findAll]];
    
    UITableView *tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300) style:UITableViewStylePlain];
    tableview.dataSource = self;
    tableview.delegate = self;
    [self.view addSubview:tableview];
    self.tableview = tableview;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableDictionary *)tasks
{
    if (!_tasks) {
        _tasks = [NSMutableDictionary dictionary];
    }
    return _tasks;
}

/** 懒加载 */
- (NSMutableArray *)downloadTaskArray {
    if (!_downloadTaskArray) {
        self.downloadTaskArray = [NSMutableArray array];
    }
    return _downloadTaskArray;
}


- (NSMutableDictionary *)sessionModels
{
    if (!_sessionModels) {
        _sessionModels = [NSMutableDictionary dictionary];
    }
    return _sessionModels;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _downloadMp4Arr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
      TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"TableViewCell%ld",(long)indexPath.row]];
    if(cell ==nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:self options:nil] lastObject];
    }
    DownLoadModel *model = _downloadMp4Arr[indexPath.row];
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *downloadPath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@mp3",model.numberID]];
    CGFloat floatpro= 0.0f;
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
        if(![[NSFileManager defaultManager] isExecutableFileAtPath:downloadPath]){
         floatpro = [self fileSizeForPath:downloadPath];
            cell.currentLable.text = [NSString stringWithFormat:@"下载：%.2f",floatpro/model.progress];
        }else{
            cell.currentLable.text = [NSString stringWithFormat:@"下载：%.2f",0.00f];
        }
    }
    
    
    cell.downLoadBtn.tag = indexPath.row+1000;
    [cell.downLoadBtn addTarget:self action:@selector(downLoadVideo:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(void)downLoadVideo:(UIButton*)btn{
    
    btn.selected = !btn.selected;
    DownLoadModel *model = [_downloadMp4Arr objectAtIndex:btn.tag-1000];
    //根据id获取当前的operation；
    AFHTTPRequestOperation *operation = [self getTask:model.urlSting];
    
    if(operation){
        if(operation.isPaused){
            [btn setTitle:@"继续中" forState:UIControlStateNormal];
            [btn setTitle:@"继续中" forState:UIControlStateHighlighted];
           [operation resume];
        }else{
            [btn setTitle:@"暂停中" forState:UIControlStateNormal];
            [btn setTitle:@"暂停中" forState:UIControlStateHighlighted];
           [operation pause];
        }
        
    }else{
        [btn setTitle:@"下载中" forState:UIControlStateNormal];
        [btn setTitle:@"下载中" forState:UIControlStateHighlighted];
       [self downloadOperation:btn.tag-1000];
    }
    
}
-(void)stopDown{
    
}


- (AFHTTPRequestOperation *)getTask:(NSString *)url
{
    return (AFHTTPRequestOperation *)[self.tasks valueForKey:url];
}



-(void)downloadOperation:(NSInteger)p{
    __block BOOL isfirst = YES;
   __block DownLoadModel *model = [_downloadMp4Arr objectAtIndex:p];
    NSString *downloadUrl = model.urlSting;
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
      NSString *downloadPath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@mp3",model.numberID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]];
    //检查文件是否已经下载了一部分
    unsigned long long downloadedBytes = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
        if(![[NSFileManager defaultManager] isExecutableFileAtPath:downloadPath]){
            //获取已下载的文件长度
            downloadedBytes = [self fileSizeForPath:downloadPath];
            if (downloadedBytes > 0) {
                NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
                NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
                [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
                request = mutableURLRequest;
            }
        }
    }
    //不使用缓存，避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    
    
        //下载请求
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        //下载路径
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:downloadPath append:YES];
        //下载进度回调
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            //下载进度
            //仅仅记录一次下载进度 如果数据库中已经存在则不存
            if(isfirst&&model.progress<1){
                model.progress = totalBytesExpectedToRead + downloadedBytes;
                [model update];
            }
            float progress = ((float)totalBytesRead + downloadedBytes) / (totalBytesExpectedToRead + downloadedBytes);
            [self updateProgressViewWithCellIndexPath:p progress:progress];
            isfirst = NO;
        }];
        //成功和失败回调
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"hahah");
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"hahah");
        }];
        [operation start];
        [self.tasks setValue:operation forKey:model.urlSting];
}

- (void)updateProgressViewWithCellIndexPath:(NSInteger )p progress:(CGFloat)progress{
    NSIndexPath *index = [NSIndexPath indexPathForRow:p inSection:0];
    TableViewCell *cell = [self.tableview cellForRowAtIndexPath:index];
    cell.currentLable.text = [NSString stringWithFormat:@"下载：%.2f",progress];
}


- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}

@end

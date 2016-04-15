# AFnetWorkingDemo
并行下载 断点续传  暂停 继续


   //下载进度
    //仅仅记录一次下载进度 如果数据库中已经存在则不存
  if(isfirst&&model.progress<1){
      model.progress = totalBytesExpectedToRead + downloadedBytes;
       [model update];
  }


获取文件大小
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

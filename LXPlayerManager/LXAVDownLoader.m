//
//  LXAVDownLoader.m
//  LXAVDownLoader
//
//  Created by Mac on 2020/5/9.
//  Copyright © 2020 李响. All rights reserved.
//

#import "LXAVDownLoader.h"
#import "LXAVFile.h"

@interface LXAVDownLoader()<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSFileHandle *fileHandle;

@end

@implementation LXAVDownLoader

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

/**
  下载某一个区间的数据
  @param url 资源路径
  @param offset 下载区间
*/
- (void)downLoadWithURL:(NSURL *)url offset:(long long)offset {
   
    self.url = url;
    self.offset = offset;

    //清除缓存
    [self cancelAndClean];
    
    // 请求的是某一个区间的数据 Range
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    [task resume];
    
}

/// 清除缓存 停止绘画
- (void)cancelAndClean {
    [self.session invalidateAndCancel];
    self.session = nil;
    
    // 清空本地已经存储的临时缓存
    [LXAVFile clearTmpFile:self.url];
    
    // 重置数据
    self.loadedSize = 0;
}

#pragma mark - NSURLSessionDataDelegate {
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    // Content-Length取出来 如果Content-Range有, 应该从Content-Range里面获取
    self.totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length != 0) {
        self.totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    //文件类型 外界需要调用
    self.mimeType = response.MIMEType;
    //流文件
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:[LXAVFile tmpFilePath:self.url] append:YES];
    [self.outputStream open];

    completionHandler(NSURLSessionResponseAllow);
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    //写文件
    [self.outputStream write:data.bytes maxLength:data.length];
    self.loadedSize += data.length;
    
    //下载回调
    if ([self.delegate respondsToSelector:@selector(avDownLoading:)]) {
        [self.delegate avDownLoading:self];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error == nil) {
           // 下载完成 但不一定下载成功 只有临时文件和资源文件大小相等 才算成功
        if ([LXAVFile tmpFileSize:self.url] == self.totalSize) {
            //移动文件 : 临时文件夹 -> cache文件夹
            [LXAVFile moveTmpPathToCachePath:self.url];
        }else {
            [LXAVFile clearTmpFile:self.url];
        }

       }else {
           // 取消,  断网
           if (error.code == -999) {
          [LXAVFile clearTmpFile:self.url];

           }else {
              
           }
       }
       [self.outputStream close];
    
}

@end

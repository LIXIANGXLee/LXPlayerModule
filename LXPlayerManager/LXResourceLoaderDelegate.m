//
//  LXResourceLoaderDelegate.m
//  LXResourceLoaderDelegate
//
//  Created by Mac on 2020/5/9.
//  Copyright © 2020 李响. All rights reserved.
//

#import "LXResourceLoaderDelegate.h"
#import "LXAVFile.h"
#import "LXAVDownLoader.h"
#import "NSURL+LXHttpStream.h"

@interface LXResourceLoaderDelegate ()<LXAVDownLoaderDelegate>

///下载器
@property (nonatomic, strong) LXAVDownLoader *downLoader;
///加载的网络请求
@property (nonatomic, strong) NSMutableArray *loadingRequests;

@end

@implementation LXResourceLoaderDelegate

- (LXAVDownLoader *)downLoader {
    if (!_downLoader) {
        _downLoader = [[LXAVDownLoader alloc] init];
        _downLoader.delegate = self;
    }
    return _downLoader;
}

- (NSMutableArray *)loadingRequests {
    if (!_loadingRequests) {
        _loadingRequests = [NSMutableArray array];
    }
    return _loadingRequests;
}

/// 当外界播放一段音视频资源时就会调一个请求, 给这个对象, 只需要根据请求信息, 抛数据给外界
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    //1.判断,本地有没有该音视频资源的缓存文件, 如果有，直接根据本地缓存, 向外界响应数据
    NSURL *url = [loadingRequest.request.URL httpURL];
    if ([LXAVFile cacheFileExists:url]) {
        [self handleLoadingRequest:loadingRequest];
        return YES;
    }
    
    // 记录所有的请求
    [self.loadingRequests addObject:loadingRequest];
    
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    long long currentOffset = loadingRequest.dataRequest.currentOffset;
    if (requestOffset != currentOffset) {
        requestOffset = currentOffset;
    }
 
    // 2. 判断有没有正在下载
    if (self.downLoader.loadedSize == 0) {
        [self.downLoader downLoadWithURL:url offset:requestOffset];
        
        return YES;
    }
    
    // 3 判断当前是否需要重新下载
    //   当资源请求, 开始点 < 下载的开始点
    //   当资源的请求, 开始点 > 下载的开始点 + 下载的长度
    if (requestOffset < self.downLoader.offset || requestOffset > (self.downLoader.offset + self.downLoader.loadedSize + 1024* 666)) {

        [self.downLoader downLoadWithURL:url offset:requestOffset];
        return YES;
    }
    
    // 开始处理资源请求 (在下载过程当中, 也要不断的判断)
    [self handleAllLoadingRequest];
    
    return YES;
}

/// 取消请求
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.loadingRequests removeObject:loadingRequest];
}

#pragma mark - LXAVDownLoaderDelegate
-(void)avDownLoading:(LXAVDownLoader *)avDownLoader{
    [self handleAllLoadingRequest];
}

#pragma mark - 私有方法
- (void)handleAllLoadingRequest {

    NSMutableArray *deleteRequests = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.loadingRequests) {
        // 1. 填充内容信息头
        NSURL *url = loadingRequest.request.URL;
        long long totalSize = self.downLoader.totalSize;
        loadingRequest.contentInformationRequest.contentLength = totalSize;
        NSString *contentType = self.downLoader.mimeType;
        loadingRequest.contentInformationRequest.contentType = contentType;
      loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
        
        // 2. 填充数据
        NSData *data = [NSData dataWithContentsOfFile:[LXAVFile tmpFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
        if (data == nil) {
            data = [NSData dataWithContentsOfFile:[LXAVFile cacheFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
        }
        
        long long requestOffset = loadingRequest.dataRequest.requestedOffset;
        long long currentOffset = loadingRequest.dataRequest.currentOffset;
        if (requestOffset != currentOffset) {
            requestOffset = currentOffset;
        }
        NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
        
        
        long long responseOffset = requestOffset - self.downLoader.offset;
        long long responseLength = MIN(self.downLoader.offset + self.downLoader.loadedSize - requestOffset, requestLength) ;
        NSData *subData = [data subdataWithRange:NSMakeRange(responseOffset, responseLength)];
        [loadingRequest.dataRequest respondWithData:subData];
           
        // 3. 完成请求(必须把所有的关于这个请求的区间数据, 都返回完之后, 才能完成这个请求)
        if (requestLength == responseLength) {
            [loadingRequest finishLoading];
            [deleteRequests addObject:loadingRequest];
        }
    }
    [self.loadingRequests removeObjectsInArray:deleteRequests];
}


/// 处理, 本地已经下载好的资源文件
- (void)handleLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    // 1. 填充相应的信息头信息
    // 计算总大小
    NSURL *url = loadingRequest.request.URL;
    long long totalSize = [LXAVFile cacheFileSize:url];
    loadingRequest.contentInformationRequest.contentLength = totalSize;
    
    NSString *contentType = [LXAVFile contentType:url];
    loadingRequest.contentInformationRequest.contentType = contentType;
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    // 2. 相应数据给外界
    NSData *data = [NSData dataWithContentsOfFile:[LXAVFile cacheFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
    
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
    
    NSData *subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    
    [loadingRequest.dataRequest respondWithData:subData];
    
    // 3. 完成本次请求(一旦,所有的数据都给完了, 才能调用完成请求方法)
    [loadingRequest finishLoading];
}


@end

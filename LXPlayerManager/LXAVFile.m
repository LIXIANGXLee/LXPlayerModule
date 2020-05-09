//
//  LXAVFile.m
//  LXAVFile
//
//  Created by Mac on 2020/5/9.
//  Copyright © 2020 李响. All rights reserved.
//
#import "LXAVFile.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation LXAVFile

/// 下载完成 -> cache + 文件名称
+ (NSString *)cacheFilePath:(NSURL *)url {
    
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:url.lastPathComponent];
}

/// 计算沙盒文件对应的文件大小
+ (long long)cacheFileSize:(NSURL *)url {
    
    if (![self cacheFileExists:url]) {
        return 0;
    }
    NSString *path = [self cacheFilePath:url];
    NSDictionary *fileInfoDic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return  [fileInfoDic[NSFileSize] longLongValue];
}

/// 判断沙盒文件是否存在
+ (BOOL)cacheFileExists:(NSURL *)url {
    
    NSString *path = [self cacheFilePath:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

///临时文件路径
+ (NSString *)tmpFilePath:(NSURL *)url {
    
    return [NSTemporaryDirectory() stringByAppendingPathComponent:url.lastPathComponent];
}

///计算临时文件大小
+ (long long)tmpFileSize:(NSURL *)url {
    
    if (![self tmpFileExists:url]) {
        return 0;
    }
    // 获取文件路径
    NSString *path = [self tmpFilePath:url];
    NSDictionary *fileInfoDic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return  [fileInfoDic[NSFileSize] longLongValue];
}

/// 判断临时文件文件存在
+ (BOOL)tmpFileExists:(NSURL *)url {
    
    NSString *path = [self tmpFilePath:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

/// 清除临时文件
+ (void)clearTmpFile:(NSURL *)url {
    
    NSString *tmpPath = [self tmpFilePath:url];
    BOOL isDirectory = YES;
    BOOL isEx = [[NSFileManager defaultManager] fileExistsAtPath:tmpPath isDirectory:&isDirectory];
    if (isEx && !isDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
    }
}

///获取文件类型
+ (NSString *)contentType:(NSURL *)url {
    
    NSString *path = [self cacheFilePath:url];
    NSString *fileExtension = path.pathExtension;
    CFStringRef contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(fileExtension), NULL);
    NSString *contentType = CFBridgingRelease(contentTypeCF);
    return contentType;
}

///移动临时文件路径到沙盒路径
+ (void)moveTmpPathToCachePath:(NSURL *)url {
    
    NSString *tmpPath = [self tmpFilePath:url];
    NSString *cachePath = [self cacheFilePath:url];
    [[NSFileManager defaultManager] moveItemAtPath:tmpPath toPath:cachePath error:nil];
}

@end

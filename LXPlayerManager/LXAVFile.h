//
//  LXAVFile.h
//  LXAVFile
//
//  Created by Mac on 2020/5/9.
//  Copyright © 2020 李响. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXAVFile : NSObject

////根据url, 获取相应的本地, 缓存路径, 下载完成的路径
+ (NSString *)cacheFilePath:(NSURL *)url;
+ (long long)cacheFileSize:(NSURL *)url;
+ (BOOL)cacheFileExists:(NSURL *)url;


+ (NSString *)tmpFilePath:(NSURL *)url;
+ (long long)tmpFileSize:(NSURL *)url;
+ (BOOL)tmpFileExists:(NSURL *)url;


+ (void)clearTmpFile:(NSURL *)url;

/** 获取文件类型 */
+ (NSString *)contentType:(NSURL *)url;
/**  移动文件路径 */
+ (void)moveTmpPathToCachePath:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END

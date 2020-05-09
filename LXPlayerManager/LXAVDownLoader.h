//
//  LXAVDownLoader.h
//  LXAVDownLoader
//
//  Created by Mac on 2020/5/9.
//  Copyright © 2020 李响. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LXAVDownLoader;
@protocol LXAVDownLoaderDelegate <NSObject>
///下载器 回调
- (void)avDownLoading:(LXAVDownLoader *)avDownLoader ;
@end


@interface LXAVDownLoader : NSObject
@property (nonatomic, weak) id<LXAVDownLoaderDelegate> delegate;

@property (nonatomic, assign) long long totalSize;
@property (nonatomic, assign) long long loadedSize;
@property (nonatomic, assign) long long offset;
@property (nonatomic, strong) NSString *mimeType;

/**
  下载某一个区间的数据
  @param url 资源路径
  @param offset 下载区间
*/
- (void)downLoadWithURL:(NSURL *)url offset:(long long)offset;

@end

NS_ASSUME_NONNULL_END

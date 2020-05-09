//
//  NSURL+LXHttpStream.h
//  LXPlayerModule
//
//  Created by Mac on 2020/5/9.
//  Copyright © 2020 李响. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (LXHttpStream)

///获取streaming协议的url地址
- (NSURL *)streamingURL;

////获取http协议的url地址
- (NSURL *)httpURL;

@end

NS_ASSUME_NONNULL_END

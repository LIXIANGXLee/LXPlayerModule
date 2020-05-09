//
//  NSURL+LXHttpStream.m
//  LXPlayerModule
//
//  Created by Mac on 2020/5/9.
//  Copyright © 2020 李响. All rights reserved.
//

#import "NSURL+LXHttpStream.h"


@implementation NSURL (LXHttpStream)
/// 转成流格式
- (NSURL *)streamingURL {
    NSURLComponents *compents = [NSURLComponents componentsWithString:self.absoluteString ];
    compents.scheme = @"streaming";
    return compents.URL;
}

/// 转成http格式
- (NSURL *)httpURL {
    NSURLComponents *compents = [NSURLComponents componentsWithString:self.absoluteString];
    compents.scheme = @"http";
    return compents.URL;
}

@end

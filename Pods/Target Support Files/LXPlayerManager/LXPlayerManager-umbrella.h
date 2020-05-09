#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LXAVDownLoader.h"
#import "LXAVFile.h"
#import "LXAVPlayerView.h"
#import "LXResourceLoaderDelegate.h"
#import "NSURL+LXHttpStream.h"

FOUNDATION_EXPORT double LXPlayerManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char LXPlayerManagerVersionString[];


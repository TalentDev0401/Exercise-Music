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

#import "REDownloadTasksQueue.h"
#import "REDownloadTasksQueue+Serialization.h"

FOUNDATION_EXPORT double REDownloadTasksQueueVersionNumber;
FOUNDATION_EXPORT const unsigned char REDownloadTasksQueueVersionString[];


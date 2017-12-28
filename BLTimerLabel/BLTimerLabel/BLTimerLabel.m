//
//  BLTimerLabel.m
//  BLTimerLabel
//
//  Created by Bluelich on 12/12/2017.
//  Copyright © 2017 Bluelich. All rights reserved.
//

#import "BLTimerLabel.h"
#import <pthread.h>

@interface BLTimerLabel ()
{
    pthread_mutex_t lock;
}
@property (nonatomic,strong)dispatch_source_t  timer;
@property (nonatomic,assign)NSUInteger         count;//执行次数
@property (nonatomic,assign)BOOL               ignore;
@end

@implementation BLTimerLabel
- (void)dealloc
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (_timer) {
        [self stopTimer];
    }
    pthread_mutex_destroy(&lock);
}
- (void)lock
{
    pthread_mutex_lock(&lock);
}
- (void)unlock
{
    pthread_mutex_unlock(&lock);
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _interval_100ms = 10;
        _count = 0;
        _counting = NO;
        _ignore = NO;
        pthread_mutex_init(&lock, NULL);
    }
    return self;
}
- (void)setInterval_100ms:(NSUInteger)interval
{
    if (_interval_100ms == interval) {
        return;
    }
    _interval_100ms = interval;
    if (_interval_100ms == 0) {
        [self stopTimer];
        return;
    }
#ifdef DEBUG
    if (_interval_100ms > 100) {
        NSLog(@"interval > 10s 请检查代码确认无误!");
    }
#endif
    if (_timer) {
        [self stopTimer];
    }
    [self lock];
    [self resetTimer];
    [self unlock];
}
- (void)setElapsedTime_100ms:(NSUInteger)elapsedTime
{
    _count = elapsedTime;
    [self update];
}
- (NSUInteger)elapsedTime_100ms
{
    return self.count;
}
- (void)resetTimer
{
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.timer, ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf.ignore) {
            return;
        }
        strongSelf.count += 1;
        NSUInteger mod = strongSelf.count % strongSelf.interval_100ms;
        if (mod == 0) {
            [strongSelf update];
        }
    });
    _ignore = NO;
}
- (void)startTimer
{
    [self lock];
    if (!_timer) {
        [self resetTimer];
    }
    if (!_counting) {
        dispatch_resume(_timer);
        _counting = YES;
    }
    [self unlock];
}
- (void)pauseTimer
{
    [self lock];
    if (self.timer && _counting) {
        dispatch_suspend(_timer);
        _counting = NO;
    }
    [self unlock];
}
- (void)continueTimer
{
    [self startTimer];
}
- (void)stopTimer
{
    [self lock];
    if (_timer) {
        if (_counting) {
            dispatch_source_cancel(_timer);
        }else{
            _ignore = YES;
            dispatch_resume(_timer);
            dispatch_source_cancel(_timer);
        }
        _timer = nil;
    }
    [self unlock];
}
- (void)update
{
    if (!_delegate) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = [_delegate callTimerLabel:self textAtTime:_count];
        self.text = str;
    });
}
@end

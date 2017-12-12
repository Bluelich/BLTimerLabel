//
//  BLTimerLabel.h
//  BLTimerLabel
//
//  Created by Bluelich on 12/12/2017.
//  Copyright © 2017 Bluelich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLTimerLabel;
@protocol BLCallTimerLabelDelegate <NSObject>
@required
-(NSString*)callTimerLabel:(BLTimerLabel *)label textAtTime:(NSUInteger)time_100ms;
@end

@interface BLTimerLabel : UILabel
/**
 时间间隔,单位100ms,默认10
 */
@property (nonatomic,assign)NSUInteger      interval_100ms;
/**
 经过的时间,单位100ms
 */
@property (nonatomic,assign)NSUInteger      elapsedTime_100ms;
@property (nonatomic,  weak)id<BLCallTimerLabelDelegate> delegate;
@property (nonatomic,assign,readonly)BOOL  counting;

- (void)startTimer;
- (void)pauseTimer;
- (void)continueTimer;
- (void)stopTimer;

@end

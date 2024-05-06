//
//  SBAwayLockBarLabel.h
//  ClassicLockScreen
//
//  Created by coolstar on 1/25/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBAwayLockBarLabel : UILabel {
    int _animationTimerCount;
}

@property (nonatomic, assign) int animationTimerCount;

- (void) setGradientLocations:(CGFloat) leftEdge;

- (void) startTimer;
- (void) stopTimer;

@end

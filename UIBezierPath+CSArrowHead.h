//
//  UIBezierPath+CSArrowHead.h
//  ClassicLockScreen
//
//  Created by coolstar on 1/3/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (CSArrowHead)

+ (UIBezierPath *)CSArrowHead_bezierPathWithArrowFromPoint:(CGPoint)startPoint
                                           toPoint:(CGPoint)endPoint
                                         tailWidth:(CGFloat)tailWidth
                                         headWidth:(CGFloat)headWidth
                                        headLength:(CGFloat)headLength;

@end

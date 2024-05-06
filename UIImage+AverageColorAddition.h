//
//  UIImage+UIImageAverageColorAddition.h
//  AvgColor
//
//  Created by nikolai on 28.08.12.
//  Copyright (c) 2012 Savoy Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImageAverageColorAddition)

- (UIColor *)averageColor;
- (UIColor *)averageColorInFrame:(CGRect)frame;
- (UIColor *)mergedColor;

@end

@interface UIColor (LightCheck)
- (BOOL)isColorLight;
@end

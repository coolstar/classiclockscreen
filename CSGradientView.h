//
//  CSGradientView.h
//  ClassicLockScreen
//
//  Created by coolstar on 1/2/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CSGradientView : UIImageView

- (CAGradientLayer *)layer;
@property (nonatomic, readonly) CAGradientLayer *layer;

@end

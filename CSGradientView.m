//
//  CSGradientView.m
//  ClassicLockScreen
//
//  Created by coolstar on 1/2/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import "CSGradientView.h"

@implementation CSGradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        // Initialization code
    }
    return self;
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

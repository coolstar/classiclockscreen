//
//  SBAwayMediaControlsVolumeView.m
//  ClassicLockScreen
//
//  Created by coolstar on 1/4/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import "SBAwayMediaControlsVolumeView.h"
#import "UIImage+AverageColorAddition.h"

extern BOOL CSCLScheckModern();
extern UIImage *getWallpaper();

@implementation SBAwayMediaControlsVolumeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        if (!CSCLScheckModern()){
#if TARGET_IPHONE_SIMULATOR
            [self setMinimumTrackImage:[[UIImage imageNamed:@"SwitcherSliderTrackMin"]resizableImageWithCapInsets:UIEdgeInsetsMake(4, 5, 4, 5)] forState:UIControlStateNormal];
            [self setMaximumTrackImage:[[UIImage imageNamed:@"SwitcherSliderTrackMax"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 5, 4, 5)] forState:UIControlStateNormal];
            [self setThumbImage:[UIImage imageNamed:@"SwitcherSliderThumb"] forState:UIControlStateNormal];
#else
            [self setMinimumVolumeSliderImage:[[UIImage imageNamed:@"SwitcherSliderTrackMin"]resizableImageWithCapInsets:UIEdgeInsetsMake(4, 5, 4, 5)] forState:UIControlStateNormal];
            [self setMaximumVolumeSliderImage:[[UIImage imageNamed:@"SwitcherSliderTrackMax"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 5, 4, 5)] forState:UIControlStateNormal];
            [self setVolumeThumbImage:[UIImage imageNamed:@"SwitcherSliderThumb"] forState:UIControlStateNormal];
#endif
        } else {
            UIImage *wallpaper = getWallpaper();

	        CGRect frame = self.frame;
	       frame.origin.x *= wallpaper.scale;
	       frame.origin.y *= wallpaper.scale;
	       frame.size.width *= wallpaper.scale;
	       frame.size.height *= wallpaper.scale;

            UIColor *avgColor = [wallpaper averageColorInFrame:frame];
#if TARGET_IPHONE_SIMULATOR
            [self setThumbImage:[UIImage imageNamed:@"ControlCenterSliderThumb"] forState:UIControlStateNormal];
            [self setMinimumTrackImage:[[UIImage imageNamed:@"CSModernVolumeBarHighlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal];
            if ([avgColor isColorLight])
                [self setMaximumTrackImage:[[UIImage imageNamed:@"CSModernVolumeBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal];
            else
                [self setMaximumTrackImage:[[UIImage imageNamed:@"CSModernVolumeBar-Light"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal];
#else
            [self setVolumeThumbImage:[UIImage imageWithContentsOfFile:@"/System/Library/PrivateFrameworks/SpringBoardUI.framework/ControlCenterSliderThumb.png"] forState:UIControlStateNormal];
            [self setMinimumVolumeSliderImage:[[UIImage imageNamed:@"CSModernVolumeBarHighlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal];
            if ([avgColor isColorLight])
                [self setMaximumVolumeSliderImage:[[UIImage imageNamed:@"CSModernVolumeBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal];
            else
                [self setMaximumVolumeSliderImage:[[UIImage imageNamed:@"CSModernVolumeBar-Light"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal];
#endif
        }
    }
    return self;
}

@end

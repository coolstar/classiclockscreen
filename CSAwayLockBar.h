//
//  CSAwayLockBar.h
//  ClassicLockScreen
//
//  Created by coolstar on 1/3/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBAwayLockBarLabel.h"
#import "CSLockScreenCameraViewController.h"

@class CSAwayLockBar,CSBackdropView;
@protocol CSAwayLockBarDelegate <NSObject>

- (void)lockBarUnlocked:(CSAwayLockBar *)lockBar;

@end

@interface CSAwayLockBar : UIImageView <UIGestureRecognizerDelegate> {
    UIImageView *_unlockSliderBorder, *_unlockSliderBackground;
    UISlider *_unlockSlider;
    SBAwayLockBarLabel *_unlockSliderText;
    UIImageView *_cameraGrabber;
    NSObject<CSAwayLockBarDelegate> *_delegate;
    CSLockScreenCameraViewController *_cameraController;
    CSBackdropView *_backdropView, *_modernSliderThumb;
    UIImageView *_backdropViewOverlay, *_modernSliderOverlay;
}

@property (nonatomic, strong) NSObject<CSAwayLockBarDelegate> *delegate;
@property (nonatomic, strong) CSBackdropView *backdropView;

- (void)resetSlider;
- (void)setSliderText:(NSString *)text;
- (void)dismissCamera;
- (void) startTimer;
- (void)stopTimer;

@end

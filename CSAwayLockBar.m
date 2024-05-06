//
//  CSAwayLockBar.m
//  ClassicLockScreen
//
//  Created by coolstar on 1/3/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import "CSAwayLockBar.h"
#import <CoreGraphics/CoreGraphics.h>
#import "UIBezierPath+CSArrowHead.h"
#import "CSAwayController.h"
#import <objc/runtime.h>
#import "CSBackdropView.h"
#import "UIImage+AverageColorAddition.h"

extern BOOL CSCLScheckModern();
extern BOOL CSCLScheckAltSlider();
extern _UIBackdropViewSettings *getBackdropSettings();

@implementation CSAwayLockBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;

        _backdropView = [[CSBackdropView alloc] initWithFrame:CGRectZero
                                                       autosizesToFitSuperview:YES settings:getBackdropSettings()];
        [self addSubview:_backdropView];

        _backdropViewOverlay = [[UIImageView alloc] initWithFrame:CGRectZero];
        _backdropViewOverlay.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_backdropViewOverlay];

        _unlockSliderBorder = [[UIImageView alloc] initWithFrame:CGRectZero];
        _unlockSliderBorder.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _unlockSliderBorder.userInteractionEnabled = YES;
        [self addSubview:_unlockSliderBorder];

        _unlockSliderText = [[SBAwayLockBarLabel alloc] initWithFrame:CGRectZero];
        _unlockSliderText.adjustsFontSizeToFitWidth = YES;
        _unlockSliderText.textColor = [UIColor whiteColor];
        _unlockSliderText.backgroundColor = [UIColor clearColor];
        #if TARGET_IPHONE_SIMULATOR
        _unlockSliderText.text = @"slide to unlock";
#else
        _unlockSliderText.text = [[NSBundle mainBundle] localizedStringForKey:@"AWAY_LOCK_LABEL" value:@"slide to unlock" table:@"SpringBoard"];
        if ([_unlockSliderText.text isEqualToString:@""])
            _unlockSliderText.text = @" "; //Backwards Compatibility Fix
#endif
        [_unlockSliderBorder addSubview:_unlockSliderText];

        _unlockSlider = [[UISlider alloc] initWithFrame:CGRectZero];
        [_unlockSlider setMinimumTrackImage:[self blankImage] forState:UIControlStateNormal];
        [_unlockSlider setMaximumTrackImage:[self blankImage] forState:UIControlStateNormal];
        _unlockSlider.continuous = YES;
        [_unlockSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [_unlockSlider addTarget:self action:@selector(sliderCancelled:) forControlEvents:UIControlEventTouchUpInside];
        [_unlockSlider addTarget:self action:@selector(sliderCancelled:) forControlEvents:UIControlEventTouchUpOutside];
        [_unlockSlider addTarget:self action:@selector(sliderStarted:) forControlEvents:UIControlEventTouchDown];
        [_unlockSliderBorder addSubview:_unlockSlider];


        _cameraGrabber = [[UIImageView alloc] initWithFrame:CGRectZero];
        _cameraGrabber.userInteractionEnabled = YES; 
        _cameraGrabber.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_cameraGrabber];

        UITapGestureRecognizer *grabberBounceRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bounceCamera:)];
        [grabberBounceRecognizer setNumberOfTapsRequired:1];
        [grabberBounceRecognizer setNumberOfTouchesRequired:1];
        [grabberBounceRecognizer setDelegate:self];
        [_cameraGrabber addGestureRecognizer:grabberBounceRecognizer];
            
        UIPanGestureRecognizer *grabberRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updatePosition:)];
        [grabberRecognizer setDelegate:self];
        [_cameraGrabber addGestureRecognizer:grabberRecognizer];
        
        _cameraController = nil;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _backdropViewOverlay.frame = self.bounds;

    _UIBackdropViewSettings *backdropSettings = getBackdropSettings();
    if (CSCLScheckModern()){
        UIImage *blurMask = [self generateBlurMask];
        if (!CSCLScheckAltSlider())
           [backdropSettings setFilterMaskImage:blurMask];
        [backdropSettings setColorTintMaskImage:blurMask];
        if ([backdropSettings respondsToSelector:@selector(setColorBurnTintMaskImage:)])
            [backdropSettings setColorBurnTintMaskImage:blurMask];
        [backdropSettings setGrayscaleTintMaskImage:blurMask];
        if ([backdropSettings respondsToSelector:@selector(setDarkeningTintMaskImage:)])
            [backdropSettings setDarkeningTintMaskImage:blurMask];
        [_backdropView transitionToSettings:backdropSettings];
        [_backdropViewOverlay setImage:[self generateOverlayImage]];

        _backdropView.alpha = 1;
        if (CSCLScheckAltSlider())
            _backdropViewOverlay.alpha = 0.1;
        else
            _backdropViewOverlay.alpha = 1.0;
        self.image = nil;
    } else {
        _backdropView.alpha = 0;
        _backdropViewOverlay.alpha = 0;

        NSString *barBottomLock = @"/System/Library/PrivateFrameworks/TelephonyUI.framework/BarBottomLock~iphone.png";
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            barBottomLock = @"/System/Library/PrivateFrameworks/TelephonyUI.framework/BarBottomLock~ipad.png";

        [self setImage:[UIImage imageWithContentsOfFile:barBottomLock]];
    }

    float addedWidth = 5;
    float addedPadding = 0;
    BOOL cameraGrabberEnabled = true;
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.coolstar.classiclockscreen.plist"]];
    if ([settings objectForKey:@"grabberEnabled"] != nil)
        cameraGrabberEnabled = [[settings objectForKey:@"grabberEnabled"] boolValue];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        addedWidth = 30;
        //addedPadding = 10;
        cameraGrabberEnabled = NO;

        addedPadding = (self.bounds.size.width - (230 + addedWidth))/2.0;
        addedPadding -= 20;
    } else {
        if (!cameraGrabberEnabled){ 
            addedWidth = 45;
        }
        addedWidth += (self.bounds.size.width - 320.0)/2.0;
    }

    _unlockSliderBorder.frame = CGRectMake(addedPadding + 20, 20, 230 + addedWidth, 52);
    if (CSCLScheckModern()){
        _unlockSliderBorder.image = nil;
        [_unlockSliderBorder setBackgroundColor:[UIColor clearColor]];
        _unlockSliderBorder.layer.cornerRadius = 10;
    } else {
        NSString *grabberImage = @"/System/Library/PrivateFrameworks/TelephonyUI.framework/WellLock~iphone.png";
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            grabberImage = @"/System/Library/PrivateFrameworks/TelephonyUI.framework/WellLock~ipad.png";
        _unlockSliderBorder.image = [[UIImage imageWithContentsOfFile:grabberImage] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 13)];
        _unlockSliderBorder.layer.cornerRadius = 0;
    }

    UIImage *thumbImage = [self generateTrackImage];
    _unlockSliderText.frame = CGRectMake(thumbImage.size.width + 5, 14, _unlockSliderBorder.bounds.size.width - (thumbImage.size.width + 10), 30);

    if (CSCLScheckModern())
        [_unlockSliderText setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:22]];
    else
        [_unlockSliderText setFont:[UIFont fontWithName:@"Helvetica" size:22]];

    CGFloat sliderWidth = 224;
    if (CSCLScheckModern())
        sliderWidth += 1;
    _unlockSlider.frame = CGRectMake(CSCLScheckModern()? 2 : 3, ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 5 : 4, sliderWidth + addedWidth, 47);

    if (_modernSliderThumb){
        [_modernSliderThumb removeFromSuperview];
        _modernSliderThumb = nil;
    }

    if (_modernSliderOverlay){
        [_modernSliderOverlay removeFromSuperview];
        _modernSliderOverlay = nil;
    }

    BOOL isLightBackground = NO;
    if (CSCLScheckModern()){
        SBWallpaperController *wallpaperController = (SBWallpaperController *)[objc_getClass("SBWallpaperController") sharedInstance];
        UIView *wallpaperView = [wallpaperController valueForKey:@"_wallpaperContainerView"];
        CGSize imageSize = CGSizeMake(wallpaperView.bounds.size.width,wallpaperView.bounds.size.height);
        if (imageSize.height == 0)
            imageSize.height = 1;
        if (imageSize.width == 0)
            imageSize.width = 1;
        UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0.3);
        [wallpaperView drawViewHierarchyInRect:CGRectMake(0,0,imageSize.width,imageSize.height) afterScreenUpdates:NO];
        UIImage *wallpaper = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        UIColor *avgColor = [wallpaper averageColorInFrame:CGRectMake(0, (wallpaper.size.height - self.bounds.size.height) * 0.3, wallpaper.size.width * 0.3, self.bounds.size.height * 0.3)];
        isLightBackground = [avgColor isColorLight];
    }

    [_unlockSlider setThumbImage:thumbImage forState:UIControlStateNormal];

    if (CSCLScheckModern()){
        [_unlockSlider setThumbImage:[self blankImageOfSize:thumbImage.size] forState:UIControlStateNormal];
        [_unlockSlider setNeedsDisplay];

        UIImageView *sliderThumb = [_unlockSlider valueForKey:@"_thumbView"];

        UIImage *modernThumbMask = [UIImage imageNamed:@"CSModernUnlockSliderThumbMask"];
        if (CSCLScheckAltSlider())
            modernThumbMask = [UIImage imageNamed:@"CSModernAltUnlockSliderThumbMask"];

        [backdropSettings setFilterMaskImage:modernThumbMask];
        [backdropSettings setColorTintMaskImage:modernThumbMask];
        if ([backdropSettings respondsToSelector:@selector(setColorBurnTintMaskImage:)])
            [backdropSettings setColorBurnTintMaskImage:modernThumbMask];
        [backdropSettings setGrayscaleTintMaskImage:modernThumbMask];
        CGFloat thumbX = [[UIScreen mainScreen] scale] == 2 ? 0.5 : 0;
        CGFloat thumbY = [[UIScreen mainScreen] scale] == 2 ? 0.5 : 0;
        if (CSCLScheckAltSlider()){
            thumbX = 0;
            thumbY = 0;
        }
        _modernSliderThumb = [[CSBackdropView alloc] initWithFrame:CGRectMake(thumbX, thumbY, modernThumbMask.size.width, modernThumbMask.size.height) autosizesToFitSuperview:NO settings:backdropSettings];
        [sliderThumb addSubview:_modernSliderThumb];

        UIImage *overlayImg = [UIImage imageNamed:@"CSModernUnlockSliderOverlay"];
        if (CSCLScheckAltSlider()){
            overlayImg = [UIImage imageNamed:@"CSModernAltUnlockSliderOverlay"];
            if (isLightBackground){
                overlayImg = [UIImage imageNamed:@"CSModernAltUnlockSliderOverlayDark"];
            }
        }
        _modernSliderOverlay = [[UIImageView alloc] initWithImage:overlayImg];
        _modernSliderOverlay.frame = sliderThumb.bounds;
        [sliderThumb addSubview:_modernSliderOverlay];
        if (CSCLScheckAltSlider() && isLightBackground)
            _modernSliderOverlay.alpha = 0.5;
    }

    UIImage *cameraImage = [UIImage imageNamed:@"CameraGrabber"];
    CGSize imageSize = cameraImage.size;
    _cameraGrabber.frame = CGRectMake(self.bounds.size.width - 50, (self.bounds.size.height-imageSize.height)/2.0, 30, imageSize.height);

    if (CSCLScheckModern())
        _cameraGrabber.image = nil;
    else
        _cameraGrabber.image = cameraImage;

    if (!cameraGrabberEnabled)
        _cameraGrabber.alpha = 0;
     else
        _cameraGrabber.alpha = 1;
}

- (void)bounceCamera:(UITapGestureRecognizer *)recognizer {
    _cameraController = [[CSLockScreenCameraViewController alloc] init];
#if TARGET_IPHONE_SIMULATOR
    _cameraController.view.layer.zPosition = -1;
#endif
    [self.superview.superview addSubview:_cameraController.view];
    __block CGRect frame = self.superview.frame;
    [_cameraController setHeight:0];
    [UIView animateWithDuration:0.15 animations:^{
        frame.origin.y -= 50;
        [_cameraController setHeight:50];
        self.superview.frame = frame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            [_cameraController setHeight:0];
            frame.origin.y = 0;
            self.superview.frame = frame;
        } completion:^(BOOL finished) {
            [_cameraController.view removeFromSuperview];
            _cameraController = nil;
        }];
    }];
}

- (void)updatePosition:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan){
        _cameraController = [[CSLockScreenCameraViewController alloc] init];
#if TARGET_IPHONE_SIMULATOR
        _cameraController.view.layer.zPosition = -1;
#endif
        [self.superview.superview addSubview:_cameraController.view];
    } else if (recognizer.state == UIGestureRecognizerStateCancelled){
        [_cameraController.view removeFromSuperview];
        _cameraController = nil;
    }
    CGPoint translation = [recognizer translationInView:_cameraGrabber];
    CGRect frame = self.superview.frame;
    frame.origin.y += translation.y;
    if (frame.origin.y > 0)
        frame.origin.y = 0;
    self.superview.frame = frame;

    [recognizer setTranslation:CGPointZero inView:_cameraGrabber];
    if (recognizer.state == UIGestureRecognizerStateEnded){
        if (frame.origin.y < -self.superview.bounds.size.height/3.0){
            frame.origin.y = -self.superview.bounds.size.height;
        } else {
            frame.origin.y = 0;
        }
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.superview.frame = frame;
                         } completion:^(BOOL finished) {
                             if (frame.origin.y == 0){
                                 [[CSAwayController sharedAwayController] restartDimTimer];
                                 [_cameraController stop];
                                 [_cameraController.view removeFromSuperview];
                                 _cameraController = nil;
                             } else if (frame.origin.y == -self.superview.bounds.size.height){
                                 [[CSAwayController sharedAwayController] cancelDimTimer];
                                 [_cameraController start];
                             }
                         }];
    }
    [_cameraController setHeight:self.superview.frame.origin.y];
    [[CSAwayController sharedAwayController] cancelDimTimer];
    [[CSAwayController sharedAwayController] restartDimTimer];
}

- (void)dismissCamera {
    CGRect frame = self.superview.frame;
    frame.origin.y = 0;
    [_cameraController stop];
    [UIView animateWithDuration:0.3 animations:^{
        [_cameraController setHeight:0];
        self.superview.frame = frame;
    } completion:^(BOOL finished) {
        [[CSAwayController sharedAwayController] restartDimTimer];
        [_cameraController.view removeFromSuperview];
        _cameraController = nil;
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (UIImage *)blankImage {
    return [self blankImageOfSize:CGSizeMake(1, 1)];
}

- (UIImage *)blankImageOfSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)generateTrackImage {
    if (CSCLScheckModern()){
        if (CSCLScheckAltSlider())
            return [UIImage imageNamed:@"CSModernAltUnlockSliderOverlay"];
        return [UIImage imageNamed:@"CSModernUnlockSliderOverlay"];
    }
#if TARGET_IPHONE_SIMULATOR
    return [UIImage imageNamed:@"bottombarknobgray"];
#else
    NSString *grabberImage = @"/System/Library/PrivateFrameworks/TelephonyUI.framework/bottombarknobgray~iphone.png";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        grabberImage = @"/System/Library/PrivateFrameworks/TelephonyUI.framework/bottombarknobgray~ipad.png";
    if ([UIImage imageWithContentsOfFile:grabberImage] != nil){
        return [UIImage imageWithContentsOfFile:grabberImage];
    }
#endif
}

- (void) sliderChanged:(id)sender {
    _unlockSliderText.alpha = 1 - (_unlockSlider.value * 3.5);
}

- (void) sliderCancelled:(id)sender {
    if (_unlockSlider.value != 1.0){
        [UIView animateWithDuration:0.125 animations:^{
            [_unlockSlider setValue:0 animated:YES];
        } completion:^(BOOL finished) {
            [self sliderChanged:0];
        }];
        [self startTimer];
    } else {
        [self stopTimer];
        [_delegate lockBarUnlocked:self];
    }
}

- (void) setSliderText:(NSString *)text {
    _unlockSliderText.text = text;
    if (CSCLScheckModern())
        [_unlockSliderText setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:22]];
    else
        [_unlockSliderText setFont:[UIFont fontWithName:@"Helvetica" size:22]];
}

- (void) sliderStarted:(id)sender {
    _unlockSliderText.animationTimerCount = 0;
    [_unlockSliderText setGradientLocations:0];
    [self stopTimer];
}

- (void)resetSlider {
    [_unlockSlider setValue:0 animated:YES];
    [self sliderChanged:0];
    [self startTimer];
}

- (void) startTimer {
    [_unlockSliderText startTimer];
}

- (void) stopTimer {
    [_unlockSliderText stopTimer];
}

- (UIImage *)generateBlurMask {
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0)
        return nil;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
    [[UIColor blackColor] setFill];
    UIRectFill(self.bounds);
    
    /*UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectOffset(_unlockSliderBorder.frame, 0, 1) cornerRadius:_unlockSliderBorder.layer.cornerRadius];
    [[UIColor clearColor] setFill];
    [bezierPath fillWithBlendMode:kCGBlendModeClear alpha:1.0];*/
    [[UIColor clearColor] setFill];
    CGRect unlockSliderFrame = CGRectMake(_unlockSliderBorder.frame.origin.x-2, _unlockSliderBorder.frame.origin.y+2, _unlockSliderBorder.frame.size.width+3.5, _unlockSliderBorder.frame.size.height-0.5);
    UIRectFillUsingBlendMode(unlockSliderFrame, kCGBlendModeClear);
    
    UIImage *unlockSliderBGMask = [[UIImage imageNamed:@"CSModernUnlockSliderBGMask"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    if (CSCLScheckAltSlider())
        unlockSliderBGMask = [[UIImage imageNamed:@"CSModernUnlockAltSliderBGMask"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 25, 25, 25)];
    [unlockSliderBGMask drawInRect:unlockSliderFrame];
    
    if (_cameraGrabber.alpha != 0){
        [[UIColor clearColor] setFill];
        CGRect cameraFrame = _cameraGrabber.frame;
        UIRectFillUsingBlendMode(cameraFrame, kCGBlendModeClear);
    
        UIImage *cameraGrabberMask = [UIImage imageNamed:@"CSModernCameraGrabberMask"];
        if (CSCLScheckAltSlider())
		  cameraGrabberMask = [UIImage imageNamed:@"CSModernAltCameraGrabberMask"];
        [cameraGrabberMask drawInRect:cameraFrame];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)generateOverlayImage {
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0)
        return nil;

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
    [[UIColor clearColor] setFill];
    UIRectFill(self.bounds);
    
    if (!CSCLScheckAltSlider()){
	   UIImage *overlay = [UIImage imageNamed:@"CSModernUnlockOverlay"];
	   [overlay drawInRect:self.bounds];
    }
    
    CGRect unlockSliderFrame = CGRectMake(_unlockSliderBorder.frame.origin.x-2, 0, _unlockSliderBorder.frame.size.width+4, self.bounds.size.height);
    
    [[UIColor clearColor] setFill];
    UIRectFillUsingBlendMode(unlockSliderFrame, kCGBlendModeClear);
    
    UIImage *sliderOverlay = [[UIImage imageNamed:@"CSModernUnlockSliderBGOverlay"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    if (CSCLScheckAltSlider())
        sliderOverlay = [[UIImage imageNamed:@"CSModernUnlockAltSliderBGOverlay"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 25, 25, 25)];
    [sliderOverlay drawInRect:unlockSliderFrame];
    
    if (_cameraGrabber.alpha != 0){
        UIImage *cameraGrabberOverlay = [UIImage imageNamed:@"CSModernCameraGrabberOverlay"];
        if (CSCLScheckAltSlider())
		cameraGrabberOverlay = [UIImage imageNamed:@"CSModernAltCameraGrabberOverlay"];
        CGRect cameraGrabberFrame = CGRectMake(_cameraGrabber.frame.origin.x, 0, cameraGrabberOverlay.size.width, self.bounds.size.height);
        
        [[UIColor clearColor] setFill];
        UIRectFillUsingBlendMode(cameraGrabberFrame, kCGBlendModeClear);
        
        [cameraGrabberOverlay drawInRect:cameraGrabberFrame];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#if TARGET_IPHONE_SIMULATOR
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self setShowsCameraGrabber:![self showsCameraGrabber]];
}
#endif

- (void)dealloc {
    _unlockSliderText = nil;
    _unlockSlider = nil;
}

@end

//
//  SBAwayFirstAlertView.m
//  ClassicLockScreen
//
//  Created by CoolStar Org. on 2/19/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import "SBAwayFirstAlertView.h"
#import "CSAwayController.h"
#import "CSBackdropView.h"

extern BOOL CSCLScheckModern();
extern BOOL CSCLScheckDarkMode();
extern _UIBackdropViewSettings *getBackdropSettings();

@implementation SBAwayFirstAlertView

- (id)initWithAppIcon:(UIImage *)icon appTitle:(NSString *)appTitle notificationText:(NSString *)notificationText bulletin:(BBBulletin *)bulletin
{
    CGRect frame = CGRectMake(10, 0, 70, 70);
    frame.size.width = 320 - 20;
    
    CGSize textSize = [notificationText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16.0] constrainedToSize:CGSizeMake(frame.size.width - 70, 900) lineBreakMode:NSLineBreakByWordWrapping];
    frame.size.height += textSize.height;
    
    _bulletin = bulletin;
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        if (!CSCLScheckModern()){
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                [self setImage:[[UIImage imageNamed:@"BulletinListLockScreenBG"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 30, 30, 30)]];
            else
                [self setImage:[[UIImage imageNamed:@"BulletinListLockScreenFirstAlertBG"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 30, 30, 30)]];
        } else {
            UIImage *mask = [[UIImage imageNamed:@"CSModernNotificationMask"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
            _UIBackdropViewSettings *settings = getBackdropSettings();
            [settings setFilterMaskImage:mask];
            if ([settings respondsToSelector:@selector(setColorBurnTintMaskImage:)])
                [settings setColorBurnTintMaskImage:mask];
            [settings setColorTintMaskImage:mask];
            if ([settings respondsToSelector:@selector(setDarkeningTintMaskImage:)])
                [settings setDarkeningTintMaskImage:mask];
            [settings setGrayscaleTintMaskImage:mask];
            CSBackdropView *backdropView = [[CSBackdropView alloc] initWithFrame:self.bounds autosizesToFitSuperview:YES settings:settings];
            [self addSubview:backdropView];
            
            UIImageView *backdropOverlayView = [[UIImageView alloc] initWithFrame:self.bounds];
            backdropOverlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            /*backdropOverlayView.layer.locations = @[@0,@1];
            if (!checkDarkMode())
                backdropOverlayView.layer.colors = @[(id)[[UIColor colorWithWhite:1.0 alpha:0.4] CGColor],(id)[[UIColor colorWithWhite:1.0 alpha:0.2] CGColor]];
            else
                backdropOverlayView.layer.colors = @[(id)[[UIColor colorWithWhite:1.0 alpha:0.1] CGColor],(id)[[UIColor colorWithWhite:1.0 alpha:0] CGColor]];
            backdropOverlayView.layer.startPoint = CGPointMake(0.5, 0);
            backdropOverlayView.layer.endPoint = CGPointMake(0.5, 1);
            backdropOverlayView.layer.cornerRadius = 15.0f;*/
            backdropOverlayView.image = [[UIImage imageNamed:@"CSModernNotificationOverlay"] resizableImageWithCapInsets:UIEdgeInsetsMake(39, 15, 39, 15)];
            [self addSubview:backdropOverlayView];
        }
        _appIconView = [[UIImageView alloc] initWithImage:icon];
        [_appIconView setBackgroundColor:[UIColor clearColor]];
        _appIconView.frame = CGRectMake(20, (frame.size.height/2.0)-(29.0/2.0), 29, 29);
        _appIconView.layer.cornerRadius = 5.0;
        _appIconView.clipsToBounds = YES;
        [self addSubview:_appIconView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 200, 20)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        if (!CSCLScheckModern())
            [_titleLabel setFont:[UIFont fontWithName:@"Helvetica Bold" size:18.0]];
        else
            [_titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18.0]];
        _titleLabel.text = appTitle;
        if (!CSCLScheckModern()){
            _titleLabel.shadowColor = [UIColor blackColor];
            _titleLabel.shadowOffset = CGSizeMake(0, -1);
        }
        [self addSubview:_titleLabel];
        
        _notificationView = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, frame.size.width - 70, frame.size.height - 50)];
        [_notificationView setBackgroundColor:[UIColor clearColor]];
        [_notificationView setTextColor:[UIColor whiteColor]];
        if (!CSCLScheckModern())
            [_notificationView setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
        else
            [_notificationView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0]];
        _notificationView.numberOfLines = 0;
        _notificationView.lineBreakMode = NSLineBreakByWordWrapping;
        _notificationView.text = notificationText;
        if (!CSCLScheckModern()){
            _notificationView.layer.shadowColor = [[UIColor blackColor] CGColor];
            _notificationView.layer.shadowOffset = CGSizeMake(0, -1);
        }
        [self addSubview:_notificationView];
        
        _unlockSliderBorder = [[CSGradientView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _unlockSliderBorder.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
#if TARGET_IPHONE_SIMULATOR
        _unlockSliderBorder.image = [[UIImage imageNamed:@"BulletinWellLock"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 13, 5, 13)];
#else
        NSString *grabberImage = @"/System/Library/PrivateFrameworks/TelephonyUI.framework/BulletinWellLock.png";
        if ([UIImage imageWithContentsOfFile:grabberImage] != nil){
            _unlockSliderBorder.image = [[UIImage imageWithContentsOfFile:grabberImage] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 13, 5, 13)];
        } else {
            _unlockSliderBorder.layer.colors = @[(id)[UIColor blackColor].CGColor,
                                                 (id)[UIColor colorWithWhite:0.39 alpha:1].CGColor];
            _unlockSliderBorder.layer.locations = @[@0,@1];
            _unlockSliderBorder.layer.startPoint = CGPointMake(0.5, 0);
            _unlockSliderBorder.layer.endPoint = CGPointMake(0.5, 1);
            _unlockSliderBorder.layer.cornerRadius = 10;
            
            /*_unlockSliderBackground = [[CSGradientView alloc] initWithFrame:CGRectMake(1, 1, 228 + addedWidth, 48)];
             _unlockSliderBackground.layer.colors = @[(id)[UIColor blackColor].CGColor,
             (id)[UIColor blackColor].CGColor,
             (id)[UIColor colorWithWhite:0.2 alpha:1].CGColor];
             _unlockSliderBackground.layer.locations = @[@0,@0.5,@1];
             _unlockSliderBackground.layer.startPoint = CGPointMake(0.5, 0);
             _unlockSliderBackground.layer.endPoint = CGPointMake(0.5, 1);
             _unlockSliderBackground.layer.cornerRadius = 10;
             
             [_unlockSliderBorder addSubview:[_unlockSliderBackground autorelease]];*/
        }
#endif
        //_unlockSliderBorder.layer.zPosition = -2;
        _unlockSliderBorder.alpha = 0;
        [self addSubview:_unlockSliderBorder];
        
        _unlockSlider = [[UISlider alloc] initWithFrame:CGRectMake(_appIconView.frame.origin.x, _appIconView.frame.origin.y, self.frame.size.width-(_appIconView.frame.origin.x*2), _appIconView.frame.size.height)];
        _unlockSliderBorder.frame = CGRectMake(_unlockSlider.frame.origin.x-1, _unlockSlider.frame.origin.y-1, _unlockSlider.frame.size.width+2, _unlockSlider.frame.size.height+2);
        UIImage *blankImage = [self blankImage];
        [_unlockSlider setThumbImage:icon forState:UIControlStateNormal];
        [_unlockSlider setMaximumTrackImage:blankImage forState:UIControlStateNormal];
        [_unlockSlider setMinimumTrackImage:blankImage forState:UIControlStateNormal];
        [_unlockSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [_unlockSlider addTarget:self action:@selector(sliderCancelled:) forControlEvents:UIControlEventTouchUpInside];
        [_unlockSlider addTarget:self action:@selector(sliderCancelled:) forControlEvents:UIControlEventTouchUpOutside];
        [_unlockSlider addTarget:self action:@selector(sliderStarted:) forControlEvents:UIControlEventTouchDown];
        _unlockSlider.continuous = YES;
        
        _unlockLabel = [[SBAwayLockBarLabel alloc] initWithFrame:CGRectMake(0, 0, 280, 20)];
        _unlockLabel.center = _unlockSlider.center;
        [_unlockLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"REMOTE_NOTIFICATIONS_LOCK_LABEL" value:@"slide to view" table:@"SpringBoard"]];
        [_unlockLabel setTextColor:[UIColor whiteColor]];
        [_unlockLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        _unlockLabel.alpha = 0;
        [self addSubview:_unlockLabel];
        [self addSubview:_unlockSlider];
        // Initialization code
    }
    return self;
}

- (void)sliderStarted:(UISlider *)slider {
    [_unlockLabel startTimer];
    _unlockLabel.alpha = 1;
    [self stopBlinking];
    _appIconView.alpha = 0;
    _notificationView.alpha = 0;
    _unlockSliderBorder.alpha = 1;
}

- (void)sliderChanged:(UISlider *)slider {
    if (slider.value != 0){
        [_unlockLabel stopTimer];
        [_unlockLabel setGradientLocations:0];
    } else
        [_unlockLabel startTimer];
    _unlockLabel.alpha = 1.0 - (_unlockSlider.value * 3.5);
}

- (void)sliderCancelled:(UISlider *)slider {
    if (slider.value == 1.0){
        [[CSAwayController sharedAwayController] setBulletinToOpenAfterUnlock:_bulletin];
        [[CSAwayController sharedAwayController] unlock];
    }
    
    [slider setValue:0 animated:YES];
    _unlockSliderBorder.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        _unlockLabel.alpha = 0;
        _appIconView.alpha = 1;
        _notificationView.alpha = 1;
    }];
    [_unlockLabel stopTimer];
    [_unlockLabel setGradientLocations:0];
}

- (void)updatePosition {
    CGRect frame = self.frame;
    NSLog(@"%@",NSStringFromCGRect(self.superview.bounds));
    frame.origin.x = (self.superview.frame.size.width/2.0) - (frame.size.width/2.0);
    frame.origin.y = (self.superview.frame.size.height/2.0) - (frame.size.height/2.0);
    self.frame = frame;
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
}

- (UIImage *)blankImage {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0.0f);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)startBlinking {
    [_blinkTimer invalidate];
    _blinkTimer = nil;
    _blinkTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(toggleAlpha) userInfo:nil repeats:YES];
    [self toggleAlpha];
}

- (void)toggleAlpha {
    [UIView animateWithDuration:0.4 animations:^{
        if (_appIconView.alpha == 0){
            _appIconView.alpha = 1;
            _unlockSlider.alpha = 1;
        } else {
            _appIconView.alpha = 0;
            _unlockSlider.alpha = 0.1;
        }
    }];
}

- (void)stopBlinking {
    [_blinkTimer invalidate];
    _blinkTimer = nil;
    _appIconView.alpha = 1;
    _unlockSlider.alpha = 1;
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

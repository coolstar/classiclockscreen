//
//  SBAwayNotificationListCell.m
//  ClassicLockScreen
//
//  Created by CoolStar Org. on 3/14/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import "SBAwayNotificationListCell.h"
#import "CSAwayController.h"
#import "CSBackdropView.h"

extern BOOL CSCLScheckModern();
extern _UIBackdropViewSettings *getBackdropSettings();

@implementation SBAwayNotificationListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //CSBackdropView *backdrop = nil;
        if (!CSCLScheckModern()){
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                [self setBackgroundColor:[UIColor clearColor]];
            else
                [self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.4]];
        } else {
            [self setBackgroundColor:[UIColor clearColor]];
            if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad){
                /*_UIBackdropViewSettings *settings = getBackdropSettings();
                backdrop = [[CSBackdropView alloc] initWithFrame:self.bounds autosizesToFitSuperview:YES settings:  settings];
                [self addSubview:[backdrop autorelease]];
                [self sendSubviewToBack:backdrop];*/
            }
        }
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [[self textLabel] setFont:[UIFont fontWithName:@"Helvetica Bold" size:16]];
        [[self detailTextLabel] setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        [[self detailTextLabel] setTextColor:[UIColor whiteColor]];
        [[self textLabel] setTextColor:[UIColor whiteColor]];
        
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
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
        _unlockSliderBorder.alpha = 0;
        [self addSubview:_unlockSliderBorder];
        
        _unlockSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 20, 280, 20)];
        UIImage *blankImage = [self blankImage];
        [_unlockSlider setMaximumTrackImage:blankImage forState:UIControlStateNormal];
        [_unlockSlider setMinimumTrackImage:blankImage forState:UIControlStateNormal];
        [_unlockSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [_unlockSlider addTarget:self action:@selector(sliderCancelled:) forControlEvents:UIControlEventTouchUpInside];
        [_unlockSlider addTarget:self action:@selector(sliderCancelled:) forControlEvents:UIControlEventTouchUpOutside];
        [_unlockSlider addTarget:self action:@selector(sliderStarted:) forControlEvents:UIControlEventTouchDown];
        _unlockSlider.continuous = YES;
        
        _unlockLabel = [[SBAwayLockBarLabel alloc] initWithFrame:CGRectMake(0, 0, 280, 20)];
        [_unlockLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"REMOTE_NOTIFICATIONS_LOCK_LABEL" value:@"slide to view" table:@"SpringBoard"]];
        [_unlockLabel setTextColor:[UIColor whiteColor]];
        [_unlockLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        _unlockLabel.alpha = 0;
        [self addSubview:_unlockLabel];
        [self addSubview:_unlockSlider];
        [self sendSubviewToBack:_unlockSliderBorder];
        //[self sendSubviewToBack:backdrop];
        
        // Initialization code
    }
    return self;
}

- (void)sliderStarted:(UISlider *)slider {
    [_unlockLabel startTimer];
    _unlockLabel.alpha = 1;
    [self stopBlinking];
    self.imageView.alpha = 0;
    self.textLabel.alpha = 0;
    self.detailTextLabel.alpha = 0;
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
        self.imageView.alpha = 1;
        self.textLabel.alpha = 1;
        self.detailTextLabel.alpha = 1;
    }];
    [_unlockLabel stopTimer];
    [_unlockLabel setGradientLocations:0];
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
        if (self.imageView.alpha == 0){
            self.imageView.alpha = 1;
            _unlockSlider.alpha = 1;
        } else {
            self.imageView.alpha = 0;
            _unlockSlider.alpha = 0;
        }
    }];
}

- (void)stopBlinking {
    [_blinkTimer invalidate];
    _blinkTimer = nil;
    self.imageView.alpha = 1;
    _unlockSlider.alpha = 1;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _unlockSlider.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.frame.size.width - (self.imageView.frame.origin.x*2), self.imageView.frame.size.height);
    _unlockSliderBorder.frame = CGRectMake(_unlockSlider.frame.origin.x-1, _unlockSlider.frame.origin.y-1, _unlockSlider.frame.size.width+2, _unlockSlider.frame.size.height+2);
    _unlockLabel.center = _unlockSlider.center;
}

@end

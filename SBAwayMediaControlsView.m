//
//  SBAwayMediaControlsView.m
//  ClassicLockScreen
//
//  Created by coolstar on 1/4/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import "SBAwayMediaControlsView.h"
#import "UIBezierPath+CSArrowHead.h"
#import "SBAwayMediaControlsVolumeView.h"
#import "UIImage+AverageColorAddition.h"
#import "Headers.h"
#import "MediaRemote.h"
#import <objc/runtime.h>

//I guess I don't have the same headers as you? You can probably comment this out when you compile
@interface MPVolumeView (ClassicLockScreen)
@property BOOL showsVolumeSlider;
@end

extern BOOL CSCLScheckModern();
extern BOOL CSCLScheckDarkMode();
extern UIImage *getWallpaper();
/*extern "C" {
    void MRMediaRemoteSetElapsedTime(double time);
}*/

@implementation SBAwayMediaControlsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;

        // Initialization code
        _scrubberBorder = [[UIView alloc] initWithFrame:CGRectZero];
        _scrubberBorder.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        _musicTime = [[UILabel alloc] initWithFrame:CGRectMake(25, 5, 50, 20)];
        [_musicTime setText:@"0:00"];
        [_musicTime setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
        [_musicTime setTextAlignment:NSTextAlignmentRight];
        [_scrubberBorder addSubview:_musicTime];
        _musicTime.alpha = 0.8;
        
        CGRect timeLeftFrame = CGRectMake(255, 5, 50, 20);
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            timeLeftFrame = CGRectMake(405, 5, 50, 20);
        _musicTimeLeft = [[UILabel alloc] initWithFrame:timeLeftFrame];
        [_musicTimeLeft setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
        [_musicTimeLeft setText:@"-0:00"];
        [_scrubberBorder addSubview:_musicTimeLeft];
        _musicTimeLeft.alpha = 0.8;
        
        CGFloat scrubberWidth = 170;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            scrubberWidth = 320;
        _musicScrubber = [[UISlider alloc] initWithFrame:CGRectMake(80, 5, scrubberWidth, 20)];
        [_musicScrubber setMaximumTrackImage:[_musicScrubber minimumTrackImageForState:UIControlStateNormal] forState:UIControlStateNormal];
        [_musicScrubber setThumbImage:[UIImage imageNamed:@"CSModernMusicScrubber"] forState:UIControlStateNormal];
        [_musicScrubber addTarget:self action:@selector(scrubToPosition) forControlEvents:UIControlEventValueChanged];
        [_scrubberBorder addSubview:_musicScrubber];
        [self addSubview:_scrubberBorder];
        
        _artistLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        _albumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_albumLabel setTextColor:[UIColor lightGrayColor]];
        [_albumLabel setTextAlignment:NSTextAlignmentCenter];
        [_albumLabel setFont:[UIFont fontWithName:@"Helvetica Bold" size:12]];
        [_albumLabel setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
        [_albumLabel setShadowOffset:CGSizeMake(0, -1)];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            UIView *labelContainer = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2.0 - 160.0, CSCLScheckModern() ? 20 : 0, 320, 100)];
            [labelContainer addSubview:_artistLabel];
            [labelContainer addSubview:_titleLabel];
            [labelContainer addSubview:_albumLabel];
            [self addSubview:labelContainer];
            labelContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        } else {
            _artistLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            _albumLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [self addSubview:_artistLabel];
            [self addSubview:_titleLabel];
            [self addSubview:_albumLabel];
        }

        _nowPlayingController = [[MPUNowPlayingController alloc] init];
        [_nowPlayingController setDelegate:self];
        [_nowPlayingController _registerForNotifications];
        [_nowPlayingController startUpdating];
        [_nowPlayingController _startUpdatingTimeInformation];
        
        _playbackControlsView = [[UIView alloc] initWithFrame:CGRectZero];

        _playPauseButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_playPauseButton addTarget:self action:@selector(_playPauseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_playbackControlsView addSubview:_playPauseButton];
        
        _nextButton = [[UIButton alloc] initWithFrame:CGRectZero];
        
        [_nextButton addTarget:self action:@selector(nextSong) forControlEvents:UIControlEventTouchUpInside];
        [_playbackControlsView addSubview:_nextButton];
        
        _prevButton = [[UIButton alloc] initWithFrame:CGRectZero];
        
        [_prevButton addTarget:self action:@selector(previousSong) forControlEvents:UIControlEventTouchUpInside];
        
        [_playbackControlsView addSubview:_prevButton];
        [self addSubview:_playbackControlsView];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad){
            _shadowTop = [[UIView alloc] initWithFrame:CGRectMake(0, 90, 320, 1)];
            [_shadowTop setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
            [self addSubview:_shadowTop];

            _shadow = [[CSGradientView alloc] initWithFrame:CGRectMake(0, 91, 320, 1)];
            _shadow.layer.colors = @[(id)[[UIColor clearColor] CGColor],
                                (id)[[UIColor colorWithWhite:0.75 alpha:0.6] CGColor],
                                (id)[[UIColor clearColor] CGColor]];
            _shadow.layer.locations = @[@0,@0.5,@1];
            _shadow.layer.startPoint = CGPointMake(0, 0.5);
            _shadow.layer.endPoint = CGPointMake(1, 0.5);
            [_shadow setBackgroundColor:[UIColor clearColor]];
            [self addSubview:_shadow];
            _playbackControlsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        }
        
        _volumeFrame = [[UIView alloc] initWithFrame:CGRectZero];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            _volumeFrame.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        } else {
            _volumeFrame.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        }
        _volumeDown = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 9, 12)];
        [_volumeFrame addSubview:_volumeDown];
        
        CGFloat offset = 243;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            offset = 170;
        _volumeUp = [[UIImageView alloc] initWithFrame:CGRectMake(offset, 0, 20, 17)];
        [_volumeFrame addSubview:_volumeUp];
        _volumeDown.alpha = _volumeUp.alpha = 0.8;
        [self addSubview:_volumeFrame];
        
        _volumeView = [[SBAwayMediaControlsVolumeView alloc] initWithFrame:CGRectZero];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            _volumeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        } else {
            _volumeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        }
#if TARGET_IPHONE_SIMULATOR
#else
        _volumeView.showsVolumeSlider = YES;
#endif
        [self addSubview:_volumeView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    UIColor *avgColor = nil;

    if (CSCLScheckModern()){
        UIImage *wallpaper = getWallpaper();
        avgColor = [wallpaper averageColor];
        if (wallpaper.size.width >= (self.frame.origin.x + self.frame.size.width) && wallpaper.size.height >= (self.frame.origin.y + self.frame.size.height))
            avgColor = [wallpaper averageColorInFrame:self.frame];

        if ([avgColor isColorLight])
            [_musicTime setTextColor:[UIColor blackColor]];
        else
            [_musicTime setTextColor:[UIColor whiteColor]];
        if ([avgColor isColorLight])
            [_musicTimeLeft setTextColor:[UIColor blackColor]];
        else
            [_musicTimeLeft setTextColor:[UIColor whiteColor]];
        if ([avgColor isColorLight])
            [_musicScrubber setMinimumTrackImage:[self imageWithColor:[UIColor colorWithWhite:0.3 alpha:0.8] ofSize:CGSizeMake(3, 3)] forState:UIControlStateNormal];
        else
            [_musicScrubber setMinimumTrackImage:[self imageWithColor:[UIColor colorWithWhite:0.7 alpha:0.8] ofSize:CGSizeMake(3, 3)] forState:UIControlStateNormal];

        if ([avgColor isColorLight])
            [_volumeDown setImage:[UIImage imageNamed:@"CSModernMediaControlsVolumeDown"]];
        else
            [_volumeDown setImage:[UIImage imageNamed:@"CSModernMediaControlsVolumeDown-Light"]];
        if ([avgColor isColorLight])
            [_volumeUp setImage:[UIImage imageNamed:@"CSModernMediaControlsVolumeUp"]];
        else
            [_volumeUp setImage:[UIImage imageNamed:@"CSModernMediaControlsVolumeUp-Light"]];
    }

    CGRect scrubberFrame = CGRectMake((self.bounds.size.width - 320)/2.0, 0, 320, 30);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        scrubberFrame = CGRectMake(self.frame.size.width/2.0 - 235.0, 0, 470, 30);
    _scrubberBorder.frame = scrubberFrame;

    CGRect artistLabelFrame = CGRectMake((self.bounds.size.width - 320)/2.0, CSCLScheckModern() ? 43 : 3, 320, 13);
    CGRect titleLabelFrame = CGRectMake((self.bounds.size.width - 320)/2.0, CSCLScheckModern() ? 18 : 16, 320, CSCLScheckModern() ? 22 : 13);
    CGRect albumLabelFrame = CGRectMake((self.bounds.size.width - 320)/2.0, 29, 320, 13);
    _artistLabel.frame = artistLabelFrame;
    _titleLabel.frame = titleLabelFrame;
    _albumLabel.frame = albumLabelFrame;

    if (!CSCLScheckModern()){
        _scrubberBorder.alpha = 0;
        _titleLabel.alpha = _artistLabel.alpha = _albumLabel.alpha = 1;
        _playPauseButton.alpha = _prevButton.alpha = _nextButton.alpha = 1.0;
        _prevButton.showsTouchWhenHighlighted = _nextButton.showsTouchWhenHighlighted = _playPauseButton.showsTouchWhenHighlighted = YES;
        _shadow.alpha = 1;
        _shadowTop.alpha = 1;
    }
    else {
        _scrubberBorder.alpha = 1;
        _titleLabel.alpha = _artistLabel.alpha = 0.8;
        _albumLabel.alpha = 0;
        _playPauseButton.alpha = _prevButton.alpha = _nextButton.alpha = 0.8;
        _prevButton.showsTouchWhenHighlighted = _nextButton.showsTouchWhenHighlighted = _playPauseButton.showsTouchWhenHighlighted = NO;
        _shadow.alpha = 0;
        _shadowTop.alpha = 0;
    }

    if (!CSCLScheckModern())
        [_artistLabel setTextColor:[UIColor lightGrayColor]];
    else {
        if ([avgColor isColorLight])
            [_artistLabel setTextColor:[UIColor blackColor]];
        else
            [_artistLabel setTextColor:[UIColor whiteColor]];
    }
    [_artistLabel setTextAlignment:NSTextAlignmentCenter];
    if (!CSCLScheckModern())
        [_artistLabel setFont:[UIFont fontWithName:@"Helvetica Bold" size:12]];
    else
        [_artistLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
    if (!CSCLScheckModern()){
        [_artistLabel setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
        [_artistLabel setShadowOffset:CGSizeMake(0, -1)];
    } else {
        [_artistLabel setShadowColor:nil];
        [_artistLabel setShadowOffset:CGSizeZero];
    }

    if (!CSCLScheckModern())
        [_titleLabel setFont:[UIFont fontWithName:@"Helvetica Bold" size:12]];
    else
        [_titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    if (!CSCLScheckModern()){
        [_titleLabel setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
        [_titleLabel setShadowOffset:CGSizeMake(0, -1)];
    } else {
        [_titleLabel setShadowColor:nil];
        [_titleLabel setShadowOffset:CGSizeZero];
    }

    _playImage = [self generatePlayImage];
    _pauseImage = [self generatePauseImage];

    UIImage *nextImg = [self generateNextImage];
    [_nextButton setImage:nextImg forState:UIControlStateNormal];
    [_prevButton setImage:[UIImage imageWithCGImage:nextImg.CGImage scale:nextImg.scale orientation:UIImageOrientationUpMirrored] forState:UIControlStateNormal];

    CGRect playPauseFrame = CGRectMake(150, 0, 21, 19);
    if (CSCLScheckModern())
        playPauseFrame = CGRectMake(150, 0, 21, 21);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        playPauseFrame = CGRectMake(85, 7, 21, 19);
    _playPauseButton.frame = playPauseFrame;

    CGRect nextFrame = CGRectMake(266, 2, 24, 14);
    if (CSCLScheckModern())
        nextFrame = CGRectMake(215, 2, 28, 17);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        nextFrame = CGRectMake(137, 9, 24, 14);
    _nextButton.frame = nextFrame;

    CGRect prevFrame = CGRectMake(30, 2, 24, 14);
    if (CSCLScheckModern())
        prevFrame = CGRectMake(75, 2, 28, 17);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        prevFrame = CGRectMake(20, 9, 24, 14);
    _prevButton.frame = prevFrame;

    CGRect playbackControlsFrame = CGRectMake((self.bounds.size.width - 320)/2.0,60,320,19);
    if (CSCLScheckModern())
        playbackControlsFrame = CGRectMake((self.bounds.size.width - 320)/2.0,70,320,21);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        playbackControlsFrame = CGRectMake(0, 37, 320, 19);
    _playbackControlsView.frame = playbackControlsFrame;

    _volumeFrame.frame = CGRectMake((self.bounds.size.width - 320)/2.0 + 33, 102, 260, 12);
    _volumeView.frame = CGRectMake((self.bounds.size.width - 320)/2.0 + (CSCLScheckModern() ? 55 : 41), CSCLScheckModern() ? 100 : 100, CSCLScheckModern() ? 213 : 243, 30);

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        _volumeFrame.frame = CGRectMake(self.bounds.size.width - (31 + 166), 39, 186, 30);
        _volumeView.frame = CGRectMake(self.bounds.size.width - (31 + 146), 33, 146, 30);
    }

    if (CSCLScheckModern())
        _volumeFrame.alpha = 1.0;
    else
        _volumeFrame.alpha = 0;
}

- (UIImage *)generatePlayImage {
    if (CSCLScheckModern()){
        UIImage *wallpaper = getWallpaper();
        UIColor *avgColor = [wallpaper averageColor];
        if (wallpaper.size.width >= (self.frame.origin.x + self.frame.size.width) && wallpaper.size.height >= (self.frame.origin.y + self.frame.size.height))
            avgColor = [wallpaper averageColorInFrame:self.frame];
        if ([avgColor isColorLight])
            return [UIImage imageNamed:@"CSModernMediaControlsPlay"];
        return [UIImage imageNamed:@"CSModernMediaControlsPlay-Light"];
    }
    if ([UIImage imageNamed:@"now-playing-transport-play"] != nil)
        return [UIImage imageNamed:@"now-playing-transport-play"];
    CSGradientView *arrowBoxPart = [[CSGradientView alloc] initWithFrame:CGRectMake(0, 0, 21, 19)];
    
    arrowBoxPart.layer.colors = @[(id)[UIColor colorWithWhite:0.90 alpha:1].CGColor,
                                  (id)[UIColor colorWithWhite:0.62 alpha:1].CGColor];
    arrowBoxPart.layer.locations = @[@0,@1];
    arrowBoxPart.layer.startPoint = CGPointMake(0.5, 0);
    arrowBoxPart.layer.endPoint = CGPointMake(0.5, 1);
    
    CAShapeLayer *shapeMask = [[CAShapeLayer alloc] init];
    shapeMask.path = [UIBezierPath CSArrowHead_bezierPathWithArrowFromPoint:CGPointMake(0, 9.5)
                                                                    toPoint:CGPointMake(21, 9.5)
                                                                  tailWidth:0
                                                                  headWidth:19
                                                                 headLength:21].CGPath;
    arrowBoxPart.layer.mask = shapeMask;
    
    UIGraphicsBeginImageContextWithOptions(arrowBoxPart.frame.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [arrowBoxPart.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)generatePauseImage {
    if (CSCLScheckModern()){
        UIImage *wallpaper = getWallpaper();
        UIColor *avgColor = [wallpaper averageColor];
        if (wallpaper.size.width >= (self.frame.origin.x + self.frame.size.width) && wallpaper.size.height >= (self.frame.origin.y + self.frame.size.height))
            avgColor = [wallpaper averageColorInFrame:self.frame];
        if ([avgColor isColorLight])
            return [UIImage imageNamed:@"CSModernMediaControlsPause"];
        return [UIImage imageNamed:@"CSModernMediaControlsPause-Light"];
    }
    if ([UIImage imageNamed:@"now-playing-transport-pause"] != nil)
        return [UIImage imageNamed:@"now-playing-transport-pause"];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 17)];
    
    CSGradientView *line = [[CSGradientView alloc] initWithFrame:CGRectMake(2, 0, 5, 17)];
    
    line.layer.colors = @[(id)[UIColor colorWithWhite:0.90 alpha:1].CGColor,
                          (id)[UIColor colorWithWhite:0.62 alpha:1].CGColor];
    line.layer.locations = @[@0,@1];
    line.layer.startPoint = CGPointMake(0.5, 0);
    line.layer.endPoint = CGPointMake(0.5, 1);
    
    [containerView addSubview:line];
    
    CSGradientView *line2 = [[CSGradientView alloc] initWithFrame:CGRectMake(12, 0, 5, 17)];
    
    line2.layer.colors = @[(id)[UIColor colorWithWhite:0.90 alpha:1].CGColor,
                           (id)[UIColor colorWithWhite:0.62 alpha:1].CGColor];
    line2.layer.locations = @[@0,@1];
    line2.layer.startPoint = CGPointMake(0.5, 0);
    line2.layer.endPoint = CGPointMake(0.5, 1);
    
    [containerView addSubview:line2];
    
    UIGraphicsBeginImageContextWithOptions(containerView.frame.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [containerView.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)generateNextImage {
    if (CSCLScheckModern()){
        UIImage *wallpaper = getWallpaper();
        UIColor *avgColor = [wallpaper averageColor];
        if (wallpaper.size.width >= (self.frame.origin.x + self.frame.size.width) && wallpaper.size.height >= (self.frame.origin.y + self.frame.size.height))
            avgColor = [wallpaper averageColorInFrame:self.frame];
        if ([avgColor isColorLight])
            return [UIImage imageNamed:@"CSModernMediaControlsForward"];
        return [UIImage imageNamed:@"CSModernMediaControlsForward-Light"];
    }
    if ([UIImage imageNamed:@"now-playing-transport-next"] != nil)
        return [UIImage imageNamed:@"now-playing-transport-next"];
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 14)];
    
    CSGradientView *arrowBoxPart = [[CSGradientView alloc] initWithFrame:CGRectMake(0, 0, 12, 14)];
    
    arrowBoxPart.layer.colors = @[(id)[UIColor colorWithWhite:0.90 alpha:1].CGColor,
                                  (id)[UIColor colorWithWhite:0.62 alpha:1].CGColor];
    arrowBoxPart.layer.locations = @[@0,@1];
    arrowBoxPart.layer.startPoint = CGPointMake(0.5, 0);
    arrowBoxPart.layer.endPoint = CGPointMake(0.5, 1);
    
    CAShapeLayer *shapeMask = [[CAShapeLayer alloc] init];
    shapeMask.path = [UIBezierPath CSArrowHead_bezierPathWithArrowFromPoint:CGPointMake(0, 7)
                                                                    toPoint:CGPointMake(12, 7)
                                                                  tailWidth:0
                                                                  headWidth:14
                                                                 headLength:12].CGPath;
    arrowBoxPart.layer.mask = shapeMask;
    
    [containerView addSubview:arrowBoxPart];
    
    CSGradientView *arrowBoxPart2 = [[CSGradientView alloc] initWithFrame:CGRectMake(12, 0, 12, 19)];
    
    arrowBoxPart2.layer.colors = @[(id)[UIColor colorWithWhite:0.90 alpha:1].CGColor,
                                  (id)[UIColor colorWithWhite:0.62 alpha:1].CGColor];
    arrowBoxPart2.layer.locations = @[@0,@1];
    arrowBoxPart2.layer.startPoint = CGPointMake(0.5, 0);
    arrowBoxPart2.layer.endPoint = CGPointMake(0.5, 1);
    
    CAShapeLayer *shapeMask2 = [[CAShapeLayer alloc] init];
    shapeMask2.path = [UIBezierPath CSArrowHead_bezierPathWithArrowFromPoint:CGPointMake(0, 7)
                                                                    toPoint:CGPointMake(12, 7)
                                                                  tailWidth:0
                                                                  headWidth:14
                                                                 headLength:12].CGPath;
    arrowBoxPart2.layer.mask = shapeMask2;
    
    [containerView addSubview:arrowBoxPart2];
    
    UIGraphicsBeginImageContextWithOptions(containerView.frame.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [containerView.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)nowPlayingController:(MPUNowPlayingController *)nowPlayingController playbackStateDidChange:(BOOL)isPlaying {
    if (isPlaying){
        [_playPauseButton setImage:_pauseImage forState:UIControlStateNormal];
    } else {
        [_playPauseButton setImage:_playImage forState:UIControlStateNormal];
    }
}

- (void)nowPlayingController:(MPUNowPlayingController *)nowPlayingController nowPlayingInfoDidChange:(NSDictionary *)nowPlayingInfo {
    _artworkView.image = [nowPlayingController currentNowPlayingArtwork];
    NSString *title = [nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoTitle"];
    NSString *artist = [nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoArtist"];
    NSString *album = [nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoAlbum"];
    _titleLabel.text = title;
    _artistLabel.text = artist;
    _albumLabel.text = album;
}

- (void)update {
    [_nowPlayingController update];
}

- (void)nowPlayingController:(MPUNowPlayingController *)arg1 elapsedTimeDidChange:(double)arg2 {
    int rawTimeHours = 0, rawTimeMinutes = 0, rawTimeSeconds = 0;
    double time = [_nowPlayingController currentElapsed];
    if (time > 3600){
        rawTimeHours = time / 3600;
        time -= rawTimeHours * 3600;
    }
    if (time > 60){
        rawTimeMinutes = time / 60;
        time -= rawTimeMinutes * 60;
    }
    rawTimeSeconds = time;
    
    NSString *timeMinutes, *timeSeconds = @"";
    timeMinutes = [NSString stringWithFormat:@"%d",rawTimeMinutes];
    if (rawTimeSeconds < 10)
        timeSeconds = [NSString stringWithFormat:@"0%d",rawTimeSeconds];
    else
        timeSeconds = [NSString stringWithFormat:@"%d",rawTimeSeconds];
    NSString *musicTime = @"";
    if (rawTimeHours > 0){
        musicTime = [NSString stringWithFormat:@"%d:%@:%@",rawTimeHours,timeMinutes,timeSeconds];
    } else {
        musicTime = [NSString stringWithFormat:@"%@:%@",timeMinutes,timeSeconds];
    }
    [_musicTime setText:musicTime];
    
    time = [_nowPlayingController currentDuration] - [_nowPlayingController currentElapsed];
    if (time > 3600){
        rawTimeHours = time / 3600;
        time -= rawTimeHours * 3600;
    }
    if (time > 60){
        rawTimeMinutes = time / 60;
        time -= rawTimeMinutes * 60;
    }
    rawTimeSeconds = time;
    
    timeMinutes = [NSString stringWithFormat:@"%d",rawTimeMinutes];
    if (rawTimeSeconds < 10)
        timeSeconds = [NSString stringWithFormat:@"0%d",rawTimeSeconds];
    else
        timeSeconds = [NSString stringWithFormat:@"%d",rawTimeSeconds];
    if (rawTimeHours > 0){
        musicTime = [NSString stringWithFormat:@"-%d:%@:%@",rawTimeHours,timeMinutes,timeSeconds];
    } else {
        musicTime = [NSString stringWithFormat:@"-%@:%@",timeMinutes,timeSeconds];
    }
    [_musicTimeLeft setText:musicTime];
    
    double progress = [_nowPlayingController currentElapsed]/[_nowPlayingController currentDuration];
    [_musicScrubber setValue:progress];
}

- (void)scrubToPosition {
    double time = [_musicScrubber value] * [_nowPlayingController currentDuration];
    MRMediaRemoteSetElapsedTime(time);
}

- (void)nextSong {
    SBMediaController *mediaController = [objc_getClass("SBMediaController") sharedInstance];
    [mediaController changeTrack:1];
}

- (void)previousSong {
    SBMediaController *mediaController = [objc_getClass("SBMediaController") sharedInstance];
    [mediaController changeTrack:-1];
}

- (void)_playPauseButtonAction:(id)sender {
    SBMediaController *mediaController = [objc_getClass("SBMediaController") sharedInstance];
    [mediaController togglePlayPause];
}

- (UIImage *)imageWithColor:(UIColor *)color ofSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [color setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (double)trackDuration {
    return [_nowPlayingController currentDuration];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    //[_nowPlayingController _unregisterForNotifications];
    [_nowPlayingController stopUpdating];
}

@end

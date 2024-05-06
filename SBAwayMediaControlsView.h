//
//  SBAwayMediaControlsView.h
//  ClassicLockScreen
//
//  Created by coolstar on 1/4/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSGradientView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MPUNowPlayingController.h"

@interface SBAwayMediaControlsView : UIImageView <MPUNowPlayingDelegate> {
	UIView *_volumeFrame;
	UIImageView *_volumeDown, *_volumeUp;
#if TARGET_IPHONE_SIMULATOR
    UISlider *_volumeView;
#else
    MPVolumeView *_volumeView;
#endif
    UILabel *_albumLabel, *_artistLabel, *_titleLabel;

    UIButton *_playPauseButton, *_nextButton, *_prevButton;
    UIView *_playbackControlsView;

    UIImage *_playImage, *_pauseImage;

    MPUNowPlayingController *_nowPlayingController;

    UIView *_scrubberBorder;
    UISlider *_musicScrubber;
    UILabel *_musicTime, *_musicTimeLeft;

    __weak UIImageView *_artworkView;

    CSGradientView *_shadow;
    UIView *_shadowTop;
}

@property (nonatomic, weak) UIImageView *artworkView;
@property (nonatomic, readonly) MPUNowPlayingController *nowPlayingController;

- (void)update;

@end

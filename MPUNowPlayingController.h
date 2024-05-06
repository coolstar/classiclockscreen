@protocol MPUNowPlayingDelegate <NSObject>
@optional
-(void)nowPlayingController:(id)controller nowPlayingApplicationDidChange:(id)nowPlayingApplication;
-(void)nowPlayingController:(id)controller elapsedTimeDidChange:(double)elapsedTime;
-(void)nowPlayingController:(id)controller playbackStateDidChange:(BOOL)playbackState;
-(void)nowPlayingController:(id)controller nowPlayingInfoDidChange:(id)nowPlayingInfo;
-(void)nowPlayingControllerDidStopListeningForNotifications:(id)nowPlayingController;
-(void)nowPlayingControllerDidBeginListeningForNotifications:(id)nowPlayingController;
@end

@interface MPUNowPlayingController : NSObject {
    BOOL _cachedArtworkDirty;
    UIImage *_cachedNowPlayingArtwork;
    double _currentDuration;
    double _currentElapsed;
    NSString *_currentNowPlayingAppDisplayID;
    BOOL _currentNowPlayingAppIsRunning;
    NSDictionary *_currentNowPlayingInfo;
    NSObject<MPUNowPlayingDelegate> *_delegate;
    int _isPlaying;
    BOOL _isRegisteredForNowPlayingNotifications;
    BOOL _isUpdatingNowPlayingApp;
    BOOL _isUpdatingNowPlayingInfo;
    BOOL _isUpdatingPlaybackState;
    double _timeInformationUpdateInterval;
}

@property(readonly) double currentDuration;
@property(readonly) double currentElapsed;
@property(readonly) UIImage * currentNowPlayingArtwork;
@property(readonly) NSDictionary * currentNowPlayingInfo;
@property NSObject<MPUNowPlayingDelegate> * delegate;
@property(readonly) BOOL isPlaying;
@property(readonly) NSString * nowPlayingAppDisplayID;
@property double timeInformationUpdateInterval;

- (void)_registerForNotifications;
- (void)_startUpdatingTimeInformation;
- (void)_stopUpdatingTimeInformation;
- (void)_unregisterForNotifications;
- (void)_updateCurrentNowPlaying;
- (void)_updateNowPlayingAppDisplayID;
- (void)_updatePlaybackState;
- (void)_updateTimeInformation;
- (double)currentDuration;
- (double)currentElapsed;
- (id)currentNowPlayingArtwork;
- (id)currentNowPlayingInfo;
- (void)dealloc;
- (id)init;
- (BOOL)isPlaying;
- (id)nowPlayingAppDisplayID;
- (void)setTimeInformationUpdateInterval:(double)arg1;
- (void)startUpdating;
- (void)stopUpdating;
- (double)timeInformationUpdateInterval;
- (void)update;

@end
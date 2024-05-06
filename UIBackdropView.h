@interface _UIBackdropViewSettings : NSObject
+ (_UIBackdropViewSettings *)settingsForStyle:(int)style;

@property(retain) UIImage * colorBurnTintMaskImage;
@property(retain) UIImage * colorTintMaskImage;
@property(retain) UIImage * darkeningTintMaskImage;
@property(retain) UIImage * filterMaskImage;
@property(retain) UIImage * grayscaleTintMaskImage;
- (void)setBlurRadius:(CGFloat)radius;
- (void)setGrayscaleTintAlpha:(CGFloat)alpha;
- (void)setDarkeningTintAlpha:(CGFloat)alpha;
- (void)setColorTintAlpha:(CGFloat)alpha;
- (void)setColorBurnTintAlpha:(CGFloat)alpha;
- (void)setBlurQuality:(NSString *)blurQuality;
@end

@interface _UIBackdropView : UIView
- (_UIBackdropView *)initWithFrame:(CGRect)frame
           autosizesToFitSuperview:(BOOL)adjusts settings:(_UIBackdropViewSettings *)settings;
- (void)transitionToSettings:(_UIBackdropViewSettings *)settings;
@end
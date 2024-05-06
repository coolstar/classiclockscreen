#import "CSClassicLockScreenSettingsManager.h"
#import <objc/runtime.h>

@implementation CSClassicLockScreenSettingsManager
+ (instancetype)sharedInstance {
    static CSClassicLockScreenSettingsManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}
- (CSClassicLockScreenSettingsManager *)init {
	self = [super init];
	_prefs = [[NSUserDefaults alloc] initWithSuiteName:@"org.coolstar.classiclockscreen"];
    [_prefs registerDefaults:@{
        @"enabled": @YES,
        @"zuluClock": @NO,
        @"secondsEnabled": @NO,
        @"modern": @YES,
        @"altslider":@NO,
        @"darkmode":@YES,
        @"albumArtwork":@YES,
        @"advsettings":@NO,
        @"hidebgforartwork":@NO
    }];
	return self;
}

- (BOOL)enabled {
	return [_prefs boolForKey:@"enabled"];
}

- (BOOL)zuluClock {
    return [_prefs boolForKey:@"zuluClock"];
}

- (BOOL)secondsEnabled {
	return [_prefs boolForKey:@"secondsEnabled"];
}

- (BOOL)modern {
    return [_prefs boolForKey:@"modern"];
}

- (BOOL)altslider {
    return [_prefs boolForKey:@"altslider"];
}

- (BOOL)darkmode {
    if ([self altslider])
        return YES;
    return [_prefs boolForKey:@"darkmode"];
}

- (BOOL)albumArtwork {
    return [_prefs boolForKey:@"albumArtwork"];
}

- (BOOL)advsettings {
    return [_prefs boolForKey:@"advsettings"];
}

- (BOOL)hidebgforartwork {
    if (![self advsettings])
        return NO;
    return [_prefs boolForKey:@"hidebgforartwork"];
}
@end
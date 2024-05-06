//
//  PLApplicationCameraViewController.h
//  ClassicLockScreen
//
//  Created by CoolStar Org. on 3/22/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#ifndef ClassicLockScreen_PLApplicationCameraViewController_h
#define ClassicLockScreen_PLApplicationCameraViewController_h

@interface PLApplicationCameraViewController : UIViewController

@end

@interface DeferredPUApplicationCameraViewController : UIViewController
- (id)initForCurrentPlatformWithSessionID:(id)arg1 usesCameraLocationBundleID:(BOOL)arg2 startPreviewImmediately:(BOOL)arg3;
- (id)initForCurrentPlatformWithSessionID:(id)arg1 startPreviewImmediately:(BOOL)arg2;
@end

#endif

//
//  CSLockScreenCameraViewController.h
//  ClassicLockScreen
//
//  Created by CoolStar Org. on 3/23/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLApplicationCameraViewController.h"

@interface CSLockScreenCameraViewController : UIViewController {
    PLApplicationCameraViewController *_cameraController;
    UIImageView *_cameraScreenshot;
    UIView *_cameraScreenshotContainer;
}
- (void)setHeight:(CGFloat)height;
- (void)start;
- (void)stop;

@end

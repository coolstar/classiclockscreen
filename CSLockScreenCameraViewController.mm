//
//  CSLockScreenCameraViewController.m
//  ClassicLockScreen
//
//  Created by CoolStar Org. on 3/23/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import "CSLockScreenCameraViewController.h"
#import "Headers.h"
#import <objc/runtime.h>
#import <cmath>

@interface CSLockScreenCameraViewController ()

@end

@implementation CSLockScreenCameraViewController

- (id)init {
    self = [super init];
    if (self){
        _cameraController = nil;
        UIImage *image = nil;
        if (kCFCoreFoundationVersionNumber < 1140){
            image = [UIImage imageNamed:@"DefaultCameraUI"];
            if ([[UIScreen mainScreen] bounds].size.height == 568.0)
                image = [UIImage imageNamed:@"DefaultCameraUI-568h"];
        } else {
            image = [UIImage imageWithContentsOfFile:@"/Applications/Camera.app/Default~iphone.png"];
            if ([[UIScreen mainScreen] bounds].size.height == 568.0)
                image = [UIImage imageNamed:@"/Applications/Camera.app/Default-568h@2x~iphone.png"];
            if ([[UIScreen mainScreen] bounds].size.height == 667.0)
                image = [UIImage imageNamed:@"/Applications/Camera.app/Default-375w-667h@2x~iphone.png"];
        }
        _cameraScreenshot = [[UIImageView alloc] initWithImage:image];
        _cameraScreenshotContainer = [[UIView alloc] initWithFrame:_cameraScreenshot.frame];
        [_cameraScreenshotContainer setBackgroundColor:[UIColor greenColor]];
        [_cameraScreenshotContainer addSubview:_cameraScreenshot];
        [_cameraScreenshotContainer setClipsToBounds:YES];
        [self.view addSubview:_cameraScreenshotContainer];
    }
    return self;
}

- (void)start {
    //_cameraController = [[objc_getClass("DeferredPUApplicationCameraViewController") alloc] init];
    if (kCFCoreFoundationVersionNumber < 1140){
        _cameraController = [[objc_getClass("DeferredPUApplicationCameraViewController") alloc] initForCurrentPlatformWithSessionID:[NSDate date] startPreviewImmediately:YES];
        [self.view addSubview:_cameraController.view];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    } else {
        if ([[objc_getClass("SBLockScreenManager") sharedInstance] respondsToSelector:@selector(dashBoardViewController)]){
            SBDashBoardViewController *dashBoardViewController = [[objc_getClass("SBLockScreenManager") sharedInstance] dashBoardViewController];
            [dashBoardViewController activateCameraAnimated:NO withActions:nil];
        } else {
            SBLockScreenViewController *lockscreenViewController = [[objc_getClass("SBLockScreenManager") sharedInstance] lockScreenViewController];
            [lockscreenViewController activateCameraAnimated:NO];
        }
    }
}

- (void)stop {
    if (kCFCoreFoundationVersionNumber < 1140){
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [_cameraController.view removeFromSuperview];
        _cameraController = nil;
    } else {
        if ([[objc_getClass("SBLockScreenManager") sharedInstance] respondsToSelector:@selector(dashBoardViewController)]){
            SBDashBoardViewController *dashBoardViewController = [[objc_getClass("SBLockScreenManager") sharedInstance] dashBoardViewController];
            [dashBoardViewController activatePage:[dashBoardViewController _indexOfMainPage] animated:NO withCompletion:nil];
        }
    }
}

- (void)setHeight:(CGFloat)height {
    height = std::abs(height);
    CGRect camFrame = _cameraScreenshotContainer.frame;
    camFrame.size.height = height;
    camFrame.origin.y = self.view.frame.size.height - camFrame.size.height;
    _cameraScreenshotContainer.frame = camFrame;

    CGRect camFrame2 = _cameraScreenshot.frame;
    camFrame2.origin.y = -camFrame.origin.y;
    _cameraScreenshot.frame = camFrame2;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self stop];
}

@end

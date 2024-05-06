//
//  CSAwayNotificationController.h
//  ClassicLockScreen
//
//  Created by CoolStar Org. on 3/14/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBBulletin.h"

@class SBAwayNotificationListCell;
@interface CSAwayNotificationController : NSObject <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *_notifications;
    UITableView *_tableView;
    SBAwayNotificationListCell *_firstCell;
    BOOL firstCellShouldBlink;
    UIView *_notificationsBackdropView;
}

+ (id)sharedInstance;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIView *notificationsBackdropView;

- (void)addNotificationWithIcon:(UIImage *)icon title:(NSString *)appTitle message:(NSString *)message bulletin:(BBBulletin *)bulletin;
- (void)removeNotificationWithBulletin:(BBBulletin *)bulletin;
- (void)clearNotifications;
- (NSInteger)notificationCount;
- (void)stopFirstCellBlinking;
- (void)adjustPosition;

@end

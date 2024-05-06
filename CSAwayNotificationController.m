//
//  CSAwayNotificationController.m
//  ClassicLockScreen
//
//  Created by CoolStar Org. on 3/14/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import "CSAwayNotificationController.h"
#import "CSAwayController.h"
#import "SBAwayNotificationListCell.h"
#import "BBBulletin.h"

static CSAwayNotificationController *sharedNCObject;

@implementation CSAwayNotificationController

- (id)init {
    self = [super init];
    if (self){
        _notifications = [[NSMutableArray alloc] init];
        firstCellShouldBlink = NO;
    }
    return self;
}

+ (id)sharedInstance {
    static dispatch_once_t p = 0;
    dispatch_once(&p, ^{
        sharedNCObject = [[self alloc] init];
    });
    return sharedNCObject;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SBAwayNotificationListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSAwayNotificationCellIdentifier"];
    if (!cell){
        cell = [[SBAwayNotificationListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CSAwayNotificationCellIdentifier"];
    }
    NSDictionary *notification = [_notifications objectAtIndex:indexPath.row];
    cell.textLabel.text = [notification objectForKey:@"title"];
    cell.detailTextLabel.text = [notification objectForKey:@"message"];
    cell.imageView.image = [notification objectForKey:@"icon"];
    cell.bulletin = [notification objectForKey:@"bulletin"];
    [cell.unlockSlider setThumbImage:[notification objectForKey:@"icon"] forState:UIControlStateNormal];
    [cell layoutSubviews];
    if (indexPath.row == 0){
        if (firstCellShouldBlink){
            [cell startBlinking];
            firstCellShouldBlink = NO;
        } else
            [cell stopBlinking];
        _firstCell = cell;
    } else {
        [cell stopBlinking];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *notification = [_notifications objectAtIndex:indexPath.row];
    CGFloat height = 25;
    height += [[notification objectForKey:@"message"] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:CGSizeMake(_tableView.frame.size.width - 143, 999.0) lineBreakMode:NSLineBreakByWordWrapping].height;
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_notifications count];
}

- (void)addNotificationWithIcon:(UIImage *)icon title:(NSString *)appTitle message:(NSString *)message bulletin:(BBBulletin *)bulletin {
    NSMutableDictionary *notification = [NSMutableDictionary dictionary];
    if (appTitle != nil)
        [notification setObject:appTitle forKey:@"title"];
    if (message != nil)
        [notification setObject:message forKey:@"message"];
    if (icon != nil)
        [notification setObject:icon forKey:@"icon"];
    if (bulletin != nil)
        [notification setObject:bulletin forKey:@"bulletin"];
    [_notifications insertObject:notification atIndex:0];
    firstCellShouldBlink = YES;
    [_tableView reloadData];
    [self adjustPosition];
}

- (NSInteger)findIndexOfBulletin:(BBBulletin *)bulletin {
    NSInteger idx = 0;
    for (NSDictionary *notification in _notifications){
        if ([[notification objectForKey:@"bulletin"] isEqual:bulletin]){
            return idx;
        }
        idx++;
    }
    return -1;
}

- (void)removeNotificationWithBulletin:(BBBulletin *)bulletin {
    NSInteger idx = [self findIndexOfBulletin:bulletin];
    if (idx == -1)
        return;
    if (idx == 0 && [_notifications count] == 1){
        CSAwayView *awayView = [[CSAwayController sharedAwayController] awayView];
        [awayView.firstNotificationView stopBlinking];
        [awayView.firstNotificationView removeFromSuperview];
        awayView.firstNotificationView = nil;
    }

    [_notifications removeObjectAtIndex:idx];
    [_tableView reloadData];
    [self adjustPosition];
}

- (void)clearNotifications {
    [_notifications removeAllObjects];
    [_tableView reloadData];
    [self adjustPosition];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
        [self adjustPosition];
}

- (void)adjustPosition {
    CGRect notificationsFrame = _tableView.frame;
    notificationsFrame.size.height = _tableView.contentSize.height - _tableView.contentOffset.y;
    if (notificationsFrame.size.height >= _tableView.frame.size.height)
        notificationsFrame.size.height = _tableView.frame.size.height;
    _notificationsBackdropView.frame = notificationsFrame;

    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
        return;
    CGFloat height = 0;
    NSInteger count = [self notificationCount];
    for (NSInteger i=0;i<count;i++){
        height += [self tableView:_tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    CGRect frame = _tableView.frame;
    frame.size.width = 320;
    frame.size.height = height + 15;
    frame.origin.x = (_tableView.superview.bounds.size.width/2.0) - (frame.size.width/2.0);
    frame.origin.y = (_tableView.superview.bounds.size.height/2.0) - (frame.size.height/2.0);
    _tableView.frame = frame;
}

- (NSInteger)notificationCount {
    return [_notifications count];
}

- (void)stopFirstCellBlinking {
    [_firstCell stopBlinking];
}

@end

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BBAction : NSObject
- (BOOL)isURLLaunchAction;
- (BOOL)isAppLaunchAction;
- (id)launchBundleID;
- (id)launchURL;
@end

@interface BBAttachments : NSObject
@end

@interface BBContent : NSObject
@end

@interface BBSound : NSObject
@end

@interface BBSectionIcon : NSObject

@end

@interface BBBulletin : NSObject <NSCopying, NSCoding> {
    unsigned int _accessoryStyle;
    NSMutableDictionary *_actions;
    int _addressBookRecordID;
    NSSet *_alertSuppressionContexts;
    BBAttachments *_attachments;
    NSString *_bulletinID;
    NSString *_bulletinVersionID;
    NSArray *_buttons;
    BOOL _clearable;
    BBContent *_content;
    NSDictionary *_context;
    NSDate *_date;
    int _dateFormatStyle;
    BOOL _dateIsAllDay;
    NSString *_dismissalID;
    NSDate *_endDate;
    NSDate *_expirationDate;
    unsigned int _expirationEvents;
    BOOL _expiresOnPublisherDeath;
    BOOL _hasEventDate;
    NSDate *_lastInterruptDate;
    NSMutableArray *_lifeAssertions;
    BBContent *_modalAlertContent;
    NSMutableSet *_observers;
    NSDate *_publicationDate;
    NSString *_publisherBulletinID;
    NSString *_publisherRecordID;
    NSDate *_recencyDate;
    NSString *_sectionID;
    int _sectionSubtype;
    BOOL _showsMessagePreview;
    BBSound *_sound;
    BBContent *_starkBannerContent;
    NSSet *_subsectionIDs;
    NSTimeZone *_timeZone;
    NSString *_unlockActionLabelOverride;
    BOOL _usesExternalSync;
    BOOL _wantsFullscreenPresentation;
    NSSet *alertSuppressionAppIDs_deprecated;
    unsigned int realertCount_deprecated;
}

@property unsigned int accessoryStyle;
@property(copy) BBAction * acknowledgeAction;
@property(retain) NSMutableDictionary * actions;
@property int addressBookRecordID;
@property(readonly) NSSet * alertSuppressionAppIDs;
@property(copy) NSSet * alertSuppressionAppIDs_deprecated;
@property(copy) NSSet * alertSuppressionContexts;
@property(copy) BBAction * alternateAction;
@property(retain) BBAttachments * attachments;
@property(readonly) BOOL bannerShowsSubtitle;
@property(copy) NSString * bulletinID;
@property(copy) NSString * bulletinVersionID;
@property(copy) NSArray * buttons;
@property BOOL clearable;
@property(readonly) BOOL coalescesWhenLocked;
@property(retain) BBContent * content;
@property(retain) NSDictionary * context;
@property(retain) NSDate * date;
@property int dateFormatStyle;
@property BOOL dateIsAllDay;
@property(copy) BBAction * defaultAction;
@property(copy) NSString * dismissalID;
@property(retain) NSDate * endDate;
@property(retain) NSDate * expirationDate;
@property unsigned int expirationEvents;
@property(copy) BBAction * expireAction;
@property BOOL expiresOnPublisherDeath;
@property(readonly) NSString * fullUnlockActionLabel;
@property BOOL hasEventDate;
@property(readonly) int iPodOutAlertType;
@property(readonly) BOOL inertWhenLocked;
@property(retain) NSDate * lastInterruptDate;
@property(retain) NSMutableArray * lifeAssertions;
@property(copy) NSString * message;
@property(readonly) unsigned int messageNumberOfLines;
@property(readonly) NSString * missedBannerDescriptionFormat;
@property(retain) BBContent * modalAlertContent;
@property(retain) NSMutableSet * observers;
@property(readonly) BOOL orderSectionUsingRecencyDate;
@property(readonly) BOOL preservesUnlockActionCase;
@property(readonly) int primaryAttachmentType;
@property(retain) NSDate * publicationDate;
@property(copy) NSString * publisherBulletinID;
@property(readonly) unsigned int realertCount;
@property unsigned int realertCount_deprecated;
@property(retain) NSDate * recencyDate;
@property(copy) NSString * recordID;
@property(copy) NSString * section;
@property(readonly) NSString * sectionDisplayName;
@property(readonly) BOOL sectionDisplaysCriticalBulletins;
@property(copy) NSString * sectionID;
@property(readonly) BBSectionIcon * sectionIcon;
@property int sectionSubtype;
@property(readonly) BOOL showsDateInFloatingLockScreenAlert;
@property BOOL showsMessagePreview;
@property(readonly) BOOL showsSubtitle;
@property(copy) BBAction * snoozeAction;
@property(retain) BBSound * sound;
@property(retain) BBContent * starkBannerContent;
@property(copy) NSSet * subsectionIDs;
@property(copy) NSString * subtitle;
@property(readonly) unsigned int subtypePriority;
@property(readonly) BOOL suppressesMessageForPrivacy;
@property(retain) NSTimeZone * timeZone;
@property(copy) NSString * title;
@property(readonly) NSString * topic;
@property(readonly) NSString * unlockActionLabel;
@property(copy) NSString * unlockActionLabelOverride;
@property BOOL usesExternalSync;
@property(readonly) BOOL usesVariableLayout;
@property(readonly) BOOL visuallyIndicatesWhenDateIsInFuture;
@property BOOL wantsFullscreenPresentation;

+ (void)addBulletinToCache:(id)arg1;
+ (id)bulletinWithBulletin:(id)arg1;
+ (id)copyCachedBulletinWithBulletinID:(id)arg1;
+ (void)killSounds;
+ (void)removeBulletinFromCache:(id)arg1;

- (id)_actionKeyForType:(int)arg1;
- (id)_responseForActionType:(int)arg1;
- (id)_safeDescription:(BOOL)arg1;
- (unsigned int)accessoryStyle;
- (void (^)())actionBlockForAction:(id)arg1;
- (id)actionBlockForButton:(id)arg1 withOrigin:(int)arg2;
- (id)actionBlockForButton:(id)arg1;
- (id)actionForResponse:(id)arg1;
- (void)addLifeAssertion:(id)arg1;
- (void)addObserver:(id)arg1;
- (int)addressBookRecordID;
- (id)alternateAction;
- (id)attachments;
- (id)attachmentsCreatingIfNecessary:(BOOL)arg1;
- (BOOL)bannerShowsSubtitle;
- (BOOL)bulletinAlertShouldOverrideQuietMode;
- (id)bulletinID;
- (id)bulletinVersionID;
- (id)buttons;
- (BOOL)clearable;
- (BOOL)coalescesWhenLocked;
- (id)composedAttachmentImage;
- (id)composedAttachmentImageForKey:(id)arg1 withObserver:(id)arg2;
- (id)composedAttachmentImageForKey:(id)arg1;
- (CGSize)composedAttachmentImageSize;
- (CGSize)composedAttachmentImageSizeForKey:(id)arg1 withObserver:(id)arg2;
- (CGSize)composedAttachmentImageSizeForKey:(id)arg1;
- (CGSize)composedAttachmentImageSizeWithObserver:(id)arg1;
- (id)composedAttachmentImageWithObserver:(id)arg1;
- (id)date;
- (int)dateFormatStyle;
- (BOOL)dateIsAllDay;
- (void)dealloc;
- (id)defaultAction;
- (void (^)())defaultActionBlock;
- (void (^)())defaultActionBlockWithOrigin:(int)arg1 canBypassPinLock:(BOOL*)arg2 requiresUnlock:(BOOL*)arg3 shouldDeactivateAwayController:(BOOL*)arg4 suitabilityFilter:(id)arg5;
- (void (^)())defaultActionBlockWithOrigin:(int)arg1;
- (id)description;
- (id)dismissalID;
- (void)encodeWithCoder:(id)arg1;
- (id)endDate;
- (id)expirationDate;
- (unsigned int)expirationEvents;
- (id)expireAction;
- (BOOL)expiresOnPublisherDeath;
- (BOOL)hasEventDate;
- (BOOL)inertWhenLocked;
- (id)init;
- (id)initWithCoder:(id)arg1;
- (void)killSound;
- (unsigned int)messageNumberOfLines;
- (id)missedBannerDescriptionFormat;
- (id)modalAlertContent;
- (unsigned int)numberOfAdditionalAttachments;
- (unsigned int)numberOfAdditionalAttachmentsOfType:(int)arg1;
- (BOOL)orderSectionUsingRecencyDate;
- (BOOL)playSound;
- (BOOL)preservesUnlockActionCase;
- (unsigned int)realertCount;
- (unsigned int)realertCount_deprecated;
- (id)recordID;
- (id)responseForAcknowledgeAction;
- (id)responseForButtonActionAtIndex:(unsigned int)arg1;
- (id)responseForDefaultAction;
- (id)responseForExpireAction;
- (id)responseForSnoozeAction;
- (id)responseSendBlock;
- (id)safeDescription;
- (id)section;
- (id)sectionDisplayName;
- (BOOL)sectionDisplaysCriticalBulletins;
- (void)setAccessoryStyle:(unsigned int)arg1;
- (void)setAddressBookRecordID:(int)arg1;
- (void)setClearable:(BOOL)arg1;
- (void)setDateFormatStyle:(int)arg1;
- (void)setDateIsAllDay:(BOOL)arg1;
- (void)setExpirationEvents:(unsigned int)arg1;
- (void)setExpiresOnPublisherDeath:(BOOL)arg1;
- (void)setHasEventDate:(BOOL)arg1;
- (void)setRealertCount_deprecated:(unsigned int)arg1;
- (void)setSectionSubtype:(int)arg1;
- (void)setShowsMessagePreview:(BOOL)arg1;
- (void)setUsesExternalSync:(BOOL)arg1;
- (void)setWantsFullscreenPresentation:(BOOL)arg1;
- (BOOL)showsDateInFloatingLockScreenAlert;
- (BOOL)showsMessagePreview;
- (BOOL)showsSubtitle;
- (id)snoozeAction;
- (id)sound;
- (id)starkBannerContent;
- (id)subsectionIDs;
- (id)subtitle;
- (unsigned int)subtypePriority;
- (BOOL)suppressesMessageForPrivacy;
- (id)syncHash;
- (BOOL)usesExternalSync;
- (BOOL)usesVariableLayout;
- (BOOL)visuallyIndicatesWhenDateIsInFuture;
- (BOOL)wantsFullscreenPresentation;

@end

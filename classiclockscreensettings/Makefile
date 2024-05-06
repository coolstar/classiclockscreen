ARCHS = armv7 arm64
include theos/makefiles/common.mk

BUNDLE_NAME = ClassicLockScreenSettings
ClassicLockScreenSettings_FILES = ClassicLockScreenSettings.mm
ClassicLockScreenSettings_INSTALL_PATH = /Library/PreferenceBundles
ClassicLockScreenSettings_FRAMEWORKS = UIKit
ClassicLockScreenSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ClassicLockScreenSettings.plist$(ECHO_END)

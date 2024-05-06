ARCHS = arm64
GO_EASY_ON_ME=1

include theos/makefiles/common.mk

TWEAK_NAME = ClassicLockScreen
ClassicLockScreen_FILES = iOS9.xm iOS10.xm $(wildcard *.mm) $(wildcard *.m)
ClassicLockScreen_FRAMEWORKS = UIKit QuartzCore CoreGraphics MediaPlayer AudioToolbox Accelerate IOKit
ClassicLockScreen_PRIVATE_FRAMEWORKS = ManagedConfiguration MediaRemote MediaPlayerUI
ClassicLockScreen_LIBRARIES = MobileGestalt z
ClassicLockScreen_CFLAGS = -fobjc-arc -include DRM.pch

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += classiclockscreensettings
SUBPROJECTS += extrainst_
SUBPROJECTS += prerm
SUBPROJECTS += classiclockscreenextractlegacy
include $(THEOS_MAKE_PATH)/aggregate.mk

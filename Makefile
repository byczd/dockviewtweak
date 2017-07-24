
THEOS_DEVICE_IP=192.168.0.151
ARCHS=armv7 arm64
TARGET=iphone:latest:8.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DockViewTweak
DockViewTweak_FILES = Tweak.xm
DockViewTweak_FRAMEWORKS=UIKit

DockViewTweak_LDFLAGS = -lz -lsqlite3.0
#DockViewTweak_CFLAGS=-Wno-pointer-to-int-cast

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += dockviewbundle
include $(THEOS_MAKE_PATH)/aggregate.mk

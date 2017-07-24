include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = DockViewBundle
DockViewBundle_FILES = hlRootListController.m
DockViewBundle_INSTALL_PATH = /Library/PreferenceBundles
DockViewBundle_FRAMEWORKS = UIKit
DockViewBundle_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/DockViewBundle.plist$(ECHO_END)

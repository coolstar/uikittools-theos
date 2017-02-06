include $(THEOS)/makefiles/common.mk

TOOL_NAME = uicache
uicache_FILES = uicache.mm csstore.cpp
uicache_CODESIGN_FLAGS=-Suicache.xml

include $(THEOS_MAKE_PATH)/tool.mk
SUBPROJECTS += uiduid
SUBPROJECTS += uiopen
SUBPROJECTS += cfversion
SUBPROJECTS += gssc
SUBPROJECTS += sbreload
SUBPROJECTS += ldrestart
SUBPROJECTS += extrainst_
include $(THEOS_MAKE_PATH)/aggregate.mk

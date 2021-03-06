LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

ifeq ($(BUILD_SAFESTRAP), true)
  COMMON_GLOBAL_CFLAGS += -DBUILD_SAFESTRAP
  COMMON_GLOBAL_CPPFLAGS += -DBUILD_SAFESTRAP
endif

LOCAL_CFLAGS := -fno-strict-aliasing

LOCAL_SRC_FILES := \
    gui.cpp \
    resources.cpp \
    pages.cpp \
    text.cpp \
    image.cpp \
    action.cpp \
    console.cpp \
    fill.cpp \
    button.cpp \
    checkbox.cpp \
    fileselector.cpp \
    progressbar.cpp \
    animation.cpp \
    object.cpp \
    slider.cpp \
    slidervalue.cpp \
    listbox.cpp \
    keyboard.cpp \
    input.cpp \
    blanktimer.cpp \
    partitionlist.cpp \
    mousecursor.cpp \
    scrolllist.cpp \
    patternpassword.cpp \
    textbox.cpp \
    terminal.cpp \
    twmsg.cpp

ifneq ($(TWRP_CUSTOM_KEYBOARD),)
    LOCAL_SRC_FILES += $(TWRP_CUSTOM_KEYBOARD)
else
    LOCAL_SRC_FILES += hardwarekeyboard.cpp
endif

LOCAL_SHARED_LIBRARIES += libminuitwrp libc libstdc++ libaosprecovery libselinux
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 26; echo $$?),0)
    LOCAL_SHARED_LIBRARIES += libziparchive
else
    LOCAL_SHARED_LIBRARIES += libminzip
    LOCAL_CFLAGS += -DUSE_MINZIP
endif
LOCAL_MODULE := libguitwrp

#TWRP_EVENT_LOGGING := true
ifeq ($(TWRP_EVENT_LOGGING), true)
    LOCAL_CFLAGS += -D_EVENT_LOGGING
endif
ifneq ($(TW_USE_KEY_CODE_TOUCH_SYNC),)
    LOCAL_CFLAGS += -DTW_USE_KEY_CODE_TOUCH_SYNC=$(TW_USE_KEY_CODE_TOUCH_SYNC)
endif

ifneq ($(TW_NO_SCREEN_BLANK),)
    LOCAL_CFLAGS += -DTW_NO_SCREEN_BLANK
endif
ifneq ($(TW_NO_SCREEN_TIMEOUT),)
    LOCAL_CFLAGS += -DTW_NO_SCREEN_TIMEOUT
endif
ifeq ($(TW_OEM_BUILD), true)
    LOCAL_CFLAGS += -DTW_OEM_BUILD
endif
ifneq ($(TW_X_OFFSET),)
    LOCAL_CFLAGS += -DTW_X_OFFSET=$(TW_X_OFFSET)
endif
ifneq ($(TW_Y_OFFSET),)
    LOCAL_CFLAGS += -DTW_Y_OFFSET=$(TW_Y_OFFSET)
endif
ifneq ($(TW_W_OFFSET),)
    LOCAL_CFLAGS += -DTW_W_OFFSET=$(TW_W_OFFSET)
endif
ifneq ($(TW_H_OFFSET),)
    LOCAL_CFLAGS += -DTW_H_OFFSET=$(TW_H_OFFSET)
endif
ifeq ($(TW_ROUND_SCREEN), true)
    LOCAL_CFLAGS += -DTW_ROUND_SCREEN
endif

ifdef BUILD_SAFESTRAP
# Safestrap virtual size defaults
ifndef BOARD_DEFAULT_VIRT_SYSTEM_SIZE
    BOARD_DEFAULT_VIRT_SYSTEM_SIZE := 600
endif
ifndef BOARD_DEFAULT_VIRT_SYSTEM_MIN_SIZE
    BOARD_DEFAULT_VIRT_SYSTEM_MIN_SIZE := 600
endif
ifndef BOARD_DEFAULT_VIRT_SYSTEM_MAX_SIZE
    BOARD_DEFAULT_VIRT_SYSTEM_MAX_SIZE := 1000
endif
LOCAL_CFLAGS += -DDEFAULT_VIRT_SYSTEM_SIZE=\"$(BOARD_DEFAULT_VIRT_SYSTEM_SIZE)\"
LOCAL_CFLAGS += -DDEFAULT_VIRT_SYSTEM_MIN_SIZE=\"$(BOARD_DEFAULT_VIRT_SYSTEM_MIN_SIZE)\"
LOCAL_CFLAGS += -DDEFAULT_VIRT_SYSTEM_MAX_SIZE=\"$(BOARD_DEFAULT_VIRT_SYSTEM_MAX_SIZE)\"
ifndef BOARD_DEFAULT_VIRT_DATA_SIZE
    BOARD_DEFAULT_VIRT_DATA_SIZE := 2000
endif
ifndef BOARD_DEFAULT_VIRT_DATA_MIN_SIZE
    BOARD_DEFAULT_VIRT_DATA_MIN_SIZE := 1000
endif
ifndef BOARD_DEFAULT_VIRT_DATA_MAX_SIZE
    BOARD_DEFAULT_VIRT_DATA_MAX_SIZE := 16000
endif
LOCAL_CFLAGS += -DDEFAULT_VIRT_DATA_SIZE=\"$(BOARD_DEFAULT_VIRT_DATA_SIZE)\"
LOCAL_CFLAGS += -DDEFAULT_VIRT_DATA_MIN_SIZE=\"$(BOARD_DEFAULT_VIRT_DATA_MIN_SIZE)\"
LOCAL_CFLAGS += -DDEFAULT_VIRT_DATA_MAX_SIZE=\"$(BOARD_DEFAULT_VIRT_DATA_MAX_SIZE)\"
ifndef BOARD_DEFAULT_VIRT_CACHE_SIZE
    BOARD_DEFAULT_VIRT_CACHE_SIZE := 300
endif
ifndef BOARD_DEFAULT_VIRT_CACHE_MIN_SIZE
    BOARD_DEFAULT_VIRT_CACHE_MIN_SIZE := 300
endif
ifndef BOARD_DEFAULT_VIRT_CACHE_MAX_SIZE
    BOARD_DEFAULT_VIRT_CACHE_MAX_SIZE := 1000
endif
LOCAL_CFLAGS += -DDEFAULT_VIRT_CACHE_SIZE=\"$(BOARD_DEFAULT_VIRT_CACHE_SIZE)\"
LOCAL_CFLAGS += -DDEFAULT_VIRT_CACHE_MIN_SIZE=\"$(BOARD_DEFAULT_VIRT_CACHE_MIN_SIZE)\"
LOCAL_CFLAGS += -DDEFAULT_VIRT_CACHE_MAX_SIZE=\"$(BOARD_DEFAULT_VIRT_CACHE_MAX_SIZE)\"
endif

LOCAL_C_INCLUDES += \
    bionic \
    system/core/include \
    system/core/libpixelflinger/include

ifeq ($(shell test $(PLATFORM_SDK_VERSION) -lt 23; echo $$?),0)
    LOCAL_C_INCLUDES += external/stlport/stlport
endif

LOCAL_CFLAGS += -DTWRES=\"$(TWRES_PATH)\"

include $(BUILD_STATIC_LIBRARY)

# Transfer in the resources for the device
include $(CLEAR_VARS)
LOCAL_MODULE := twrp
LOCAL_MODULE_TAGS := eng
LOCAL_MODULE_CLASS := RECOVERY_EXECUTABLES
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)

# The extra blank line before *** is intentional to ensure it ends up on its own line
define TW_THEME_WARNING_MSG

****************************************************************************
  Could not find ui.xml for TW_THEME: $(TW_THEME)
  Set TARGET_SCREEN_WIDTH and TARGET_SCREEN_HEIGHT to automatically select
  an appropriate theme, or set TW_THEME to one of the following:
    $(notdir $(wildcard $(commands_recovery_local_path)/gui/theme/*_*))
****************************************************************************
endef
define TW_CUSTOM_THEME_WARNING_MSG

****************************************************************************
  Could not find ui.xml for TW_CUSTOM_THEME: $(TW_CUSTOM_THEME)
  Expected to find custom theme's ui.xml at:
    $(TWRP_THEME_LOC)/ui.xml
  Please fix this or set TW_THEME to one of the following:
    $(notdir $(wildcard $(commands_recovery_local_path)/gui/theme/*_*))
****************************************************************************
endef

ifdef BUILD_SAFESTRAP
SS_COMMON := $(commands_recovery_local_path)/safestrap
TWRP_RES := $(SS_COMMON)/theme/common/fonts
TWRP_RES += $(SS_COMMON)/theme/common/languages
ifeq ($(TW_EXTRA_LANGUAGES),true)
    TWRP_RES += $(SS_COMMON)/theme/extra-languages/fonts
    TWRP_RES += $(SS_COMMON)/theme/extra-languages/languages
endif
else
TWRP_RES := $(commands_recovery_local_path)/gui/theme/common/fonts
TWRP_RES += $(commands_recovery_local_path)/gui/theme/common/languages
ifeq ($(TW_EXTRA_LANGUAGES),true)
    TWRP_RES += $(commands_recovery_local_path)/gui/theme/extra-languages/fonts
    TWRP_RES += $(commands_recovery_local_path)/gui/theme/extra-languages/languages
endif
endif

ifeq ($(TW_CUSTOM_THEME),)
    ifeq ($(TW_THEME),)
        ifeq ($(DEVICE_RESOLUTION),)
            GUI_WIDTH := $(TARGET_SCREEN_WIDTH)
            GUI_HEIGHT := $(TARGET_SCREEN_HEIGHT)
        else
            SPLIT_DEVICE_RESOLUTION := $(subst x, ,$(DEVICE_RESOLUTION))
            GUI_WIDTH := $(word 1, $(SPLIT_DEVICE_RESOLUTION))
            GUI_HEIGHT := $(word 2, $(SPLIT_DEVICE_RESOLUTION))
        endif

        # Minimum resolution of 100x100
        # This also ensures GUI_WIDTH and GUI_HEIGHT are numbers
        ifeq ($(shell test $(GUI_WIDTH) -ge 100; echo $$?),0)
        ifeq ($(shell test $(GUI_HEIGHT) -ge 100; echo $$?),0)
            ifeq ($(shell test $(GUI_WIDTH) -gt $(GUI_HEIGHT); echo $$?),0)
                ifeq ($(shell test $(GUI_WIDTH) -ge 1280; echo $$?),0)
                    TW_THEME := landscape_hdpi
                else
                    TW_THEME := landscape_mdpi
                endif
            else ifeq ($(shell test $(GUI_WIDTH) -lt $(GUI_HEIGHT); echo $$?),0)
                ifeq ($(shell test $(GUI_WIDTH) -ge 720; echo $$?),0)
                    TW_THEME := portrait_hdpi
                else
                    TW_THEME := portrait_mdpi
                endif
            else ifeq ($(shell test $(GUI_WIDTH) -eq $(GUI_HEIGHT); echo $$?),0)
                # watch_hdpi does not yet exist
                TW_THEME := watch_mdpi
            endif
        endif
        endif
    endif
ifdef BUILD_SAFESTRAP
    TWRP_THEME_LOC := $(SS_COMMON)/theme/$(TW_THEME)
else
    TWRP_THEME_LOC := $(commands_recovery_local_path)/gui/theme/$(TW_THEME)
endif
    ifeq ($(wildcard $(TWRP_THEME_LOC)/ui.xml),)
        $(warning $(TW_THEME_WARNING_MSG))
        $(error Theme selection failed; exiting)
    endif

ifdef BUILD_SAFESTRAP
    TWRP_RES += $(SS_COMMON)/theme/common/$(word 1,$(subst _, ,$(TW_THEME))).xml
else
    TWRP_RES += $(commands_recovery_local_path)/gui/theme/common/$(word 1,$(subst _, ,$(TW_THEME))).xml
endif
    # for future copying of used include xmls and fonts:
    # UI_XML := $(TWRP_THEME_LOC)/ui.xml
    # TWRP_INCLUDE_XMLS := $(shell xmllint --xpath '/recovery/include/xmlfile/@name' $(UI_XML)|sed -n 's/[^\"]*\"\([^\"]*\)\"[^\"]*/\1\n/gp'|sort|uniq)
    # TWRP_FONTS_TTF := $(shell xmllint --xpath '/recovery/resources/font/@filename' $(UI_XML)|sed -n 's/[^\"]*\"\([^\"]*\)\"[^\"]*/\1\n/gp'|sort|uniq)niq)
else
    TWRP_THEME_LOC := $(TW_CUSTOM_THEME)
    ifeq ($(wildcard $(TWRP_THEME_LOC)/ui.xml),)
        $(warning $(TW_CUSTOM_THEME_WARNING_MSG))
        $(error Theme selection failed; exiting)
    endif
endif

TWRP_RES += $(TW_ADDITIONAL_RES)

TWRP_RES_GEN := $(intermediates)/twrp
$(TWRP_RES_GEN):
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)
	cp -fr $(TWRP_RES) $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)
	cp -fr $(TWRP_THEME_LOC)/* $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)
ifdef BUILD_SAFESTRAP
	# Safestrap Setup
	rm -rf $(OUT)/2nd-init-files
	rm -rf $(OUT)/APP
	rm -rf $(OUT)/install-files
	mkdir -p $(OUT)/2nd-init-files
	mkdir -p $(OUT)/install-files/etc/safestrap/flags
	mkdir -p $(OUT)/install-files/etc/safestrap/res
	mkdir -p $(OUT)/APP
	cp -p $(SS_COMMON)/devices/common/2nd-init-files/* $(OUT)/2nd-init-files
	cp -p $(SS_COMMON)/devices/common/2nd-init-files/fixboot.sh $(OUT)/recovery/root/sbin/
	cp -p $(SS_COMMON)/devices/common/2nd-init-files/ss_function.sh $(OUT)/recovery/root/sbin/
	cp -p $(SS_COMMON)/devices/common/2nd-init-files/ss_function.sh $(OUT)/install-files/etc/safestrap/
	cp -p $(SS_COMMON)/devices/common/APP/* $(OUT)/APP/
	cp -p $(SS_COMMON)/devices/common/sbin/* $(OUT)/recovery/root/sbin/
	cp -p $(SS_COMMON)/flags/* $(OUT)/install-files/etc/safestrap/flags/
	cp -p $(SS_COMMON)/bbx $(OUT)/install-files/etc/safestrap/bbx
	cp -p $(SS_COMMON)/lfs $(TARGET_RECOVERY_ROOT_OUT)/sbin/lfs
	cp -p $(SS_COMMON)/devices/common/splashscreen-res/$(DEVICE_RESOLUTION)/* $(OUT)/install-files/etc/safestrap/res/
	# Call out to device-specific script
	$(SS_COMMON)/devices/$(SS_PRODUCT_MANUFACTURER)/$(TARGET_DEVICE)/build-safestrap.sh
endif

LOCAL_GENERATED_SOURCES := $(TWRP_RES_GEN)
LOCAL_SRC_FILES := twrp $(TWRP_RES_GEN)
include $(BUILD_PREBUILT)

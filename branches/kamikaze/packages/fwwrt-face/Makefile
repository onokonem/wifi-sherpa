#
# Copyright (C) 2009 Djarvur.net, www.djarvur.net, info@djarvur.net
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fwwrt-face
PKG_VERSION:=4
PKG_RELEASE:=1

#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=http://luaforge.net/frs/download.php/2475/
#PKG_MD5SUM:=06bd2256990e507009012e2591e522ec

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/fwwrt-face
  SUBMENU:=LuCI
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=LuCI based FWWRT athentication portal
  #URL:=http://fwwrt-face.luaforge.net/
  DEPENDS:=+luci-admin-core
endef

#MAKE_FLAGS += LD="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include -pedantic -Wall -fpic" LDFLAGS="$(TARGET_LDFLAGS) -shared -fpic"
MAKE_FLAGS += BUILD_DIR="$(BUILD_DIR)"

define Build/Prepare
	$(CP) ./files/src/* $(PKG_BUILD_DIR)/
	$(call Build/Prepare/Default)
endef

#define Build/Compile
#	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS)
#endef

define Build/Install
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)
	$(CP) $(PKG_BUILD_DIR)/dist/* $(PKG_INSTALL_DIR)/
endef

#define Build/InstallDev
#	$(INSTALL_DIR) $(1)/usr/lib/lua/
#	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/syslog.so $(1)/usr/lib/lua/
#endef

define Package/fwwrt-face/install
	$(INSTALL_DIR) $(1)/
	$(CP) $(PKG_INSTALL_DIR)/* $(1)/
endef

$(eval $(call BuildPackage,fwwrt-face))

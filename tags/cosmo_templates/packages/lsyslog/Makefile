#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lsyslog
PKG_VERSION:=5
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://luaforge.net/frs/download.php/4166/
PKG_MD5SUM:=5455be27d5d806f42450b62dab3939f2

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/lsyslog
  SUBMENU:=Lua
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=A Lua wrapper for the syslog C API
  URL:=http://lsyslog.luaforge.net/
  DEPENDS:=+lua
endef

MAKE_FLAGS += LD="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include -pedantic -Wall -fpic" LDFLAGS="$(TARGET_LDFLAGS) -shared -fpic"

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) so
endef

define Build/Install
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/syslog.so $(PKG_INSTALL_DIR)/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/syslog.so $(1)/usr/lib/lua/
endef

define Package/lsyslog/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/syslog.so $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,lsyslog))

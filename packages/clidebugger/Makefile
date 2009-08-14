#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=clidebugger
PKG_VERSION:=2656
PKG_RELEASE:=1

PKG_SOURCE:=debugger.lua
PKG_SOURCE_URL:=http://luaforge.net/frs/download.php/2498/
PKG_MD5SUM:=6a15a2eef6c0ddaf630acf934ed093ba

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/clidebugger
  SUBMENU:=Lua
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=A simple command line interface debugger for Lua 5.1
  URL:=http://luaforge.net/projects/clidebugger/
  DEPENDS:+=lua
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	wget "$(PKG_SOURCE_URL)/$(PKG_SOURCE)" -O "$(PKG_BUILD_DIR)/$(PKG_SOURCE)"
endef

define Build/Compile
	# Nothing to be done
endef

define Build/Install
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/$(PKG_SOURCE) $(PKG_INSTALL_DIR)/
endef

define Package/clidebugger/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/$(PKG_SOURCE) $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,clidebugger))

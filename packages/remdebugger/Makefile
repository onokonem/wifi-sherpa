#
# Copyright (C) 2009 Djarvur.net, www.djarvur.net, admin@djarvur.net
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=remdebugger
PKG_VERSION:=1.0
PKG_RELEASE:=2

PKG_SOURCE:=remdebug-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://luaforge.net/frs/download.php/1694/
PKG_MD5SUM:=7215e676488c83bd8e14c263bc342bde

PKG_BUILD_DIR:=$(BUILD_DIR)/remdebug-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/remdebugger
  SUBMENU:=Lua
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=Remote Debugger for the Lua programming language
  URL:=http://www.keplerproject.org/remdebug
  DEPENDS:=+lua +luasocket +luafilesystem
endef

define Build/Compile
	# Nothing to be done
endef

define Build/Install
	$(INSTALL_DIR)  $(PKG_INSTALL_DIR)/usr/bin
	$(INSTALL_BIN)  $(PKG_BUILD_DIR)/src/controller.lua $(PKG_INSTALL_DIR)/usr/bin/remdebug-controller.lua
	$(INSTALL_DIR)  $(PKG_INSTALL_DIR)/usr/lib/lua/remdebug/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/remdebug/engine.lua $(PKG_INSTALL_DIR)/usr/lib/lua/remdebug/engine.lua
endef

define Package/remdebugger/install
	$(INSTALL_DIR)  $(1)/usr/bin
	$(INSTALL_BIN)  $(PKG_INSTALL_DIR)/usr/bin/remdebug-controller.lua $(1)/usr/bin/
	$(INSTALL_DIR)  $(1)/usr/lib/lua/remdebug/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)//usr/lib/lua/remdebug/engine.lua $(1)/usr/lib/lua/remdebug/
endef

$(eval $(call BuildPackage,remdebugger))

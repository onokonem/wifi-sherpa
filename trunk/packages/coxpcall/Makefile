#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=coxpcall
PKG_VERSION:=1.13.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://luaforge.net/frs/download.php/3406/
PKG_MD5SUM:=d3e0554dc426a7a24e372780b3dd5fe6

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/coxpcall
  SUBMENU:=Lua
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=Coroutine-safe xpcall and pcall versions
  URL:=http://coxpcall.luaforge.net/
  DEPENDS:=+lua
endef

define Build/Compile
	# Nothing to be done
endef

define Package/coxpcall/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/* $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,coxpcall))

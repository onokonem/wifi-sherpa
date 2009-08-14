#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=xavante-ssl
PKG_VERSION:=2.0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/xavante-$(PKG_VERSION)

PKG_SOURCE:=xavante-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://luaforge.net/frs/download.php/3966/
PKG_MD5SUM:=522f1423c76c737aa6fbdd079b1c19b6

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/xavante-ssl
  SUBMENU:=Lua
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=A Lua Web Server with WSAPI support, SSL-enabled
  URL:=http://www.keplerproject.org/xavante/
  DEPENDS:+=lua copas-ssl
endef

MAKE_FLAGS += PREFIX="$(PKG_INSTALL_DIR)/usr"

define Package/xavante-ssl/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/xavante/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/* $(1)/usr/lib/lua/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/xavante/* $(1)/usr/lib/lua/xavante/
	$(CP) ./files/usr/lib/lua/kepler_init.lua $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,xavante-ssl))

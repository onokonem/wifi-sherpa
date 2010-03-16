#
# Copyright (C) 2009 Djarvur.net, www.djarvur.net, info@djarvur.net
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wsapi
PKG_VERSION:=1.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://luaforge.net/frs/download.php/3935/
PKG_MD5SUM:=6a872e60b091d15561a26e283a047ba7

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/wsapi
  SUBMENU:=Lua
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=Lua Web Server API
  URL:=http://wsapi.luaforge.net/
  DEPENDS:=+lua
endef

define Build/Compile
	# Nothing to be done
endef

define Package/wsapi/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/wsapi/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/wsapi/* $(1)/usr/lib/lua/wsapi/
endef

$(eval $(call BuildPackage,wsapi))

#
# Copyright (C) 2009 Djarvur.net, www.djarvur.net, info@djarvur.net
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luamd5
PKG_VERSION:=1.1.2
PKG_RELEASE:=1
# md5-1.1.2.tar.gz
PKG_SOURCE:=md5-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://luaforge.net/frs/download.php/3355/
PKG_MD5SUM:=68874cff64547f2157d5ecdc3572b544

PKG_BUILD_DIR:=$(BUILD_DIR)/md5-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/luamd5
  SUBMENU:=Lua
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=Cryptographic Library for Lua
  URL:=http://www.keplerproject.org/md5/
  DEPENDS:=+lua
endef

MAKE_FLAGS += PREFIX="$(PKG_INSTALL_DIR)/usr" LD="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include -pedantic -Wall -fpic" LDFLAGS="$(TARGET_LDFLAGS) -shared -fpic"

define Package/luamd5/install
	$(INSTALL_DIR)  $(1)/usr/lib/lua/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/* $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,luamd5))

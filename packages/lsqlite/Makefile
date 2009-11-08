#
# Copyright (C) 2009 Djarvur.net, www.djarvur.net, admin@djarvur.net
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lsqlite
PKG_VERSION:=3-6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://luaforge.net/frs/download.php/2565/
PKG_MD5SUM:=368da52fc52b9c5ba122f8f348db332b

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/lsqlite
  SUBMENU:=Lua
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=Binding to SQLite 3 databases
  URL:=http://luaforge.net/projects/luasqlite/
  DEPENDS:=+lua +libsqlite3
endef

MAKE_FLAGS += PREFIX="$(PKG_INSTALL_DIR)/usr" LD="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include -L$(STAGING_DIR)/usr/lib -pedantic -Wall -fpic -ldl -lm" LDFLAGS="$(TARGET_LDFLAGS) -shared -fpic"

#define Build/Compile
#	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) linux
#endef
#
#define Build/Install
#	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/usr/lib/lua/
#	$(call Build/Install/Default)
#endef

define Package/lsqlite/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/* $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,lsqlite))

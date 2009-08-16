#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luasql
PKG_VERSION:=2.1.1
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://luaforge.net/frs/download.php/2686/
PKG_MD5SUM:=63bdd57de4b9d1be336ba112d8cb69eb

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

MAKE_FLAGS+= PREFIX="$(PKG_INSTALL_DIR)/usr" LD="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include -L$(STAGING_DIR)/usr/lib -pedantic -Wall -fpic" LDFLAGS="$(TARGET_LDFLAGS) -shared -fpic"

#define Build/Compile
#	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) linux
#endef
#
#define Build/Install
#	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/usr/lib/lua/
#	$(call Build/Install/Default)
#endef

define Package/luasql/Default
	SUBMENU:=Lua
	SECTION:=fwwrt
	CATEGORY:=FWWRT
	TITLE:=Database connectivity for the Lua
	URL:=http://www.keplerproject.org/luasql/
	DEPENDS:=+lua
endef

define Package/luasql-sqlite2
	$(call Package/luasql/Default)
	TITLE+=, sqlite2 driver
	DEPENDS+= +libsqlite
endef

define Build/luasql-sqlite2/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) T="sqlite" DRIVER_LIBS=" -lsqlite" lib
endef


define Package/luasql-sqlite2/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/* $(1)/usr/lib/lua/
endef


define Package/luasql-sqlite3
	$(call Package/luasql/Default)
	TITLE+=, sqlite3 driver
	DEPENDS+= +libsqlite3
endef

define Build/luasql-sqlite3/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) T="sqlite3" DRIVER_LIBS=" -lsqlite3" lib
endef

define Package/luasql-sqlite3/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/* $(1)/usr/lib/lua/
endef

define Package/luasql-mysql
	$(call Package/luasql/Default)
	TITLE+=, mysql driver
	DEPENDS+= +libmysql
endef

define Build/luasql-mysql/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) T="mysql" DRIVER_LIBS=" -lmysqlclient -lz" lib
endef

define Package/luasql-mysql/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/* $(1)/usr/lib/lua/
endef


define Package/luasql-pgsql
	$(call Package/luasql/Default)
	TITLE+=, postgres driver
	DEPENDS+= +libpgsql
endef

define Build/luasql-pgsql/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) T="pgsql" DRIVER_LIBS=" -lpq" lib
endef

define Package/luasql-pgsql/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/* $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,luasql-sqlite2))
$(eval $(call BuildPackage,luasql-sqlite3))
$(eval $(call BuildPackage,luasql-mysql))
$(eval $(call BuildPackage,luasql-pgsql))

#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luasql
PKG_VERSION:=2.1.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://luaforge.net/frs/download.php/2686/
PKG_MD5SUM:=63bdd57de4b9d1be336ba112d8cb69eb

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

MAKE_FLAGS += PREFIX="$(PKG_INSTALL_DIR)/usr" LD="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include -L$(STAGING_DIR)/usr/lib -pedantic -Wall -fpic" LDFLAGS="$(TARGET_LDFLAGS) -shared -fpic"

#define Build/Compile
#	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) linux
#endef
#
#define Build/Install
#	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/usr/lib/lua/
#	$(call Build/Install/Default)
#endef

define Package/luasql-sqlite2
  SUBMENU:=Lua
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=Database connectivity for the Lua, sqlite2 driver
  URL:=http://www.keplerproject.org/luasql/
  DEPENDS:=+lua +libsqlite
endef

define Build/luasql-sqlite2/Compile
	MAKE_FLAGS += T="sqlite" DRIVER_LIBS=" -lsqlite"
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) lib
endef


define Package/luasql-sqlite2/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/* $(1)/usr/lib/lua/
endef


define Package/luasql-sqlite3
  SUBMENU:=Lua
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=Database connectivity for the Lua, sqlite3 driver
  URL:=http://www.keplerproject.org/luasql/
  DEPENDS:=+lua +libsqlite3
endef

define Build/luasql-sqlite3/Compile
	MAKE_FLAGS += T="sqlite3" DRIVER_LIBS=" -lsqlite3"
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) lib
endef

define Package/luasql-sqlite3/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/* $(1)/usr/lib/lua/
endef

define Package/luasql-mysql
  SUBMENU:=Lua
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=Database connectivity for the Lua, mysql driver
  URL:=http://www.keplerproject.org/luasql/
  DEPENDS:=+lua +libmysql
endef

define Build/luasql-mysql/Compile
	MAKE_FLAGS += T="mysql" DRIVER_LIBS=" -lmysqlclient -lz"
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) lib
endef

define Package/luasql-mysql/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/* $(1)/usr/lib/lua/
endef


define Package/luasql-pgsql
  SUBMENU:=Lua
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=Database connectivity for the Lua, postgres driver
  URL:=http://www.keplerproject.org/luasql/
  DEPENDS:=+lua +libpgsql
endef

define Build/luasql-pgsql/Compile
	MAKE_FLAGS += T="pgsql" DRIVER_LIBS=" -lpq"
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) lib
endef

define Package/luasql-pgsql/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/* $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,luasql))

#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luasql
PKG_VERSION:=2.1.1
PKG_RELEASE:=6

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://luaforge.net/frs/download.php/2686/
PKG_MD5SUM:=63bdd57de4b9d1be336ba112d8cb69eb

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

COMPILE_LIST= 
DRIVER_LIBS_LIST= 
INSTALL_LIST= 

MAKE_FLAGS+= PREFIX="$(PKG_INSTALL_DIR)/usr" LD="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include -L$(STAGING_DIR)/usr/lib -pedantic -Wall -fpic" LDFLAGS="$(TARGET_LDFLAGS) -shared -fpic"

define Build/Configure
        echo "CALL luasql/Build/Configure"
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) DRIVER_LIBS="$(DRIVER_LIBS_LIST)" $(COMPILE_LIST)
endef

define Build/Install
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) $(INSTALL_LIST)
endef


define Package/luasql/Default
	SECTION:=fwwrt
	CATEGORY:=FWWRT
	TITLE:=Database connectivity for the Lua
	URL:=http://www.keplerproject.org/luasql/
	DEPENDS:=+lua
	SUBMENU:=Lua
endef

define Package/luasql-sqlite2
	$(call Package/luasql/Default)
	TITLE+=, sqlite2 driver
	DEPENDS+= +libsqlite2
endef

ifneq ($(CONFIG_PACKAGE_luasql-sqlite2),)
DRIVER_LIBS_LIST+= -lsqlite
COMPILE_LIST+= sqlite_lib
INSTALL_LIST+= sqlite_install
endif

define Package/luasql-sqlite2/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luasql/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/luasql/sqlite.so $(1)/usr/lib/lua/luasql/
endef

define Package/luasql-sqlite3
	$(call Package/luasql/Default)
	TITLE+=, sqlite3 driver
	DEPENDS+= +libsqlite3
endef

ifneq ($(CONFIG_PACKAGE_luasql-sqlite3),)
DRIVER_LIBS_LIST+= -lsqlite3
COMPILE_LIST+= sqlite3_lib
INSTALL_LIST+= sqlite3_install
endif

define Package/luasql-sqlite3/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luasql/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/luasql/sqlite3.so $(1)/usr/lib/lua/luasql/
endef

define Package/luasql-mysql
	$(call Package/luasql/Default)
	TITLE+=, mysql driver
	DEPENDS+= +libmysqlclient
endef

ifneq ($(CONFIG_PACKAGE_luasql-mysql),)
DRIVER_LIBS_LIST+= -lmysqlclient -lz
COMPILE_LIST+= mysql_lib
INSTALL_LIST+= mysql_install
endif

define Package/luasql-mysql/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luasql/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/luasql/mysql.so $(1)/usr/lib/lua/luasql/
endef

define Package/luasql-pgsql
	$(call Package/luasql/Default)
	TITLE+=, postgres driver
	DEPENDS+= +libpq
endef

ifneq ($(CONFIG_PACKAGE_luasql-pgsql),)
DRIVER_LIBS_LIST+= -lpq
COMPILE_LIST+= postgres_lib
INSTALL_LIST+= postgres_install
endif

define Package/luasql-pgsql/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luasql/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/luasql/postgres.so $(1)/usr/lib/lua/luasql/
endef

$(eval $(call BuildPackage,luasql-sqlite2))
$(eval $(call BuildPackage,luasql-sqlite3))
$(eval $(call BuildPackage,luasql-mysql))
$(eval $(call BuildPackage,luasql-pgsql))

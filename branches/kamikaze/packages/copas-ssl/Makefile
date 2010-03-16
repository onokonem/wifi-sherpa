#
# Copyright (C) 2009 Djarvur.net, www.djarvur.net, info@djarvur.net
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=copas-ssl
PKG_VERSION:=1.1.5
PKG_RELEASE:=2

PKG_BUILD_DIR:=$(BUILD_DIR)/copas-$(PKG_VERSION)

PKG_SOURCE:=copas-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://luaforge.net/frs/download.php/4027/
PKG_MD5SUM:=89b78f2d9a9d13c35a35756f2471f059

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/copas-ssl
  SUBMENU:=Lua
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=CoroutineOrientedPortableAsyncServices for Lua, SSL-enabled
  URL:=http://www.keplerproject.org/copas/
  DEPENDS:=+lua +luasec +coxpcall
endef

MAKE_FLAGS += PREFIX="$(PKG_INSTALL_DIR)/usr"

define Package/Compile
	# Nothing to be done
endef

define Package/copas-ssl/install
	$(INSTALL_DIR)  $(1)/usr/lib/lua/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/copas.lua $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,copas-ssl))

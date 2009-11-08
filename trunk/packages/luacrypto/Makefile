#
# Copyright (C) 2009 Djarvur.net, www.djarvur.net, admin@djarvur.net
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luacrypto
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://luaforge.net/frs/download.php/1722/
PKG_MD5SUM:=1e1319d960f0760b113b3e7ad9a3607d

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/luacrypto
  SUBMENU:=Lua
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=A Lua frontend to OpenSSL cryptographic library
  URL:=http://luacrypto.luaforge.net/
  DEPENDS:=+lua +libopenssl
endef

MAKE_FLAGS += PREFIX="$(PKG_INSTALL_DIR)/usr" LD="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include -pedantic -Wall -fpic" LDFLAGS="$(TARGET_LDFLAGS) -shared -fpic"

define Package/luacrypto/install
	$(INSTALL_DIR)  $(1)/usr/lib/lua/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/lcrypto.so.$(PKG_VERSION) $(1)/usr/lib/lua/crypto.so
endef

$(eval $(call BuildPackage,luacrypto))

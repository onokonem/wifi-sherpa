#
# Copyright (C) 2009 Djarvur.net, www.djarvur.net, admin@djarvur.net
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-wsapi
PKG_VERSION:=2656
PKG_RELEASE:=1

PKG_SOURCE:=wsapi.lua
PKG_SOURCE_URL:=http://svn.luci.subsignal.org/luci/tags/0.8.6/libs/sgi-wsapi/luasrc/sgi/
PKG_MD5SUM:=77ae30e4bbbb0b1950ed60d9166e1fdd

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/luci-wsapi
  SUBMENU:=LuCI
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=WSAPI wrapper for LuCI
  URL:=http://luci.freifunk-halle.net/
  DEPENDS:=+luci-admin-core +wsapi
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	svn --force export "$(PKG_SOURCE_URL)" "$(PKG_BUILD_DIR)"
endef

define Build/Compile
	# Nothing to be done
endef

define Build/Install
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/$(PKG_SOURCE) $(PKG_INSTALL_DIR)/
endef

define Package/luci-wsapi/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/sgi/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/$(PKG_SOURCE) $(1)/usr/lib/lua/luci/sgi/
endef

$(eval $(call BuildPackage,luci-wsapi))

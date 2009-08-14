#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cosmo
PKG_VERSION:=8.04.04
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://luaforge.net/frs/download.php/3286/
PKG_MD5SUM:=fc7676d1b13198f9d3d3135ba6ca6b6c

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/cosmo
  SUBMENU:=Lua
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=Safe Templates in Lua
  URL:=http://cosmo.luaforge.net/
  DEPENDS:+=lua
endef

define Package/cosmo/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/* $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,cosmo))

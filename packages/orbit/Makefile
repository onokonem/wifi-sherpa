#
# Copyright (C) 2009 Djarvur.net, www.djarvur.net, admin@djarvur.net
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=orbit
PKG_VERSION:=2.0.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://luaforge.net/frs/download.php/3975/
PKG_MD5SUM:=9ff095b915825ea9dd731b20c3772c2e

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/orbit
  SUBMENU:=Lua
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=MVC for Lua Web Development
  URL:=http://orbit.luaforge.net/
  DEPENDS:=+wsapi +luafilesystem +cosmo
endef

define Package/orbit/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/* $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,orbit))

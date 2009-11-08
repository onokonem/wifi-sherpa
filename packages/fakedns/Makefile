#
# Copyright (C) 2009 Djarvur.net, www.djarvur.net, admin@djarvur.net
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fakedns
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=http://fakedns.googlecode.com/files/
#PKG_MD5SUM:=4ebd2d74e887e6f9d6f23067a4ad8272

#PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/fakedns
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=Start a dnsmasq in fake mode
  DEPENDS:=+dnsmasq
endef


define Build/Configure
	# No configure required
endef

define Build/Compile
	# No compile required
endef

define Package/fakedns/install
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/etc/init.d/fakedns   $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,fakedns))


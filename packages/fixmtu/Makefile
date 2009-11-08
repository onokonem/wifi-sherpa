#
# Copyright (C) 2009 Djarvur.net, www.djarvur.net, admin@djarvur.net
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fixmtu
PKG_VERSION:=0.0.1
PKG_RELEASE:=5

include $(INCLUDE_DIR)/package.mk

define Package/fixmtu
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=Adds an MTU fix lines to iptables
  DEPENDS:=+fwwrt-uci-config +iptables
endef


define Build/Configure
	# Nothing to be done
endef

define Build/Compile
	# Nothing to be done
endef

define Package/fixmtu/install
	$(INSTALL_DIR)  $(1)/etc/init.d/
	$(INSTALL_BIN)  ./files/etc/init.d/fixmtu $(1)/etc/init.d/
	$(INSTALL_DATA) ./files/etc/firewall.fixmtu    $(1)/etc/
endef

$(eval $(call BuildPackage,fixmtu))

#
# Copyright (C) 2009 Djarvur.net, www.djarvur.net, info@djarvur.net
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=multiwan
PKG_VERSION:=0.0.1
PKG_RELEASE:=1.1

include $(INCLUDE_DIR)/package.mk

define Package/multiwan
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=Set Static Routes On Dynamic Interfaces
  DEPENDS:=+ip +uci +iptables
endef


define Build/Configure
	# No configure required
endef

define Build/Compile
	# No compile required
endef

define Package/multiwan/install
	$(INSTALL_DIR)  $(1)/etc/init.d/
	$(INSTALL_BIN)  ./files/etc/init.d/multiwan-config      $(1)/etc/init.d/
	$(INSTALL_BIN)  ./files/etc/init.d/multiwan-routekeeper $(1)/etc/init.d/

	$(INSTALL_DIR)  $(1)/etc/hotplug.d/firewall/
	$(INSTALL_BIN)  ./files/etc/hotplug.d/firewall/50-multiwan           $(1)/etc/hotplug.d/firewall/
	$(INSTALL_BIN)  ./files/etc/hotplug.d/firewall/55-multiwan-miniupnpd $(1)/etc/hotplug.d/firewall/

	$(INSTALL_DIR)  $(1)/sbin/
	$(INSTALL_BIN)  ./files/sbin/multiwan-routing.sh     $(1)/sbin/
	$(INSTALL_BIN)  ./files/sbin/multiwan-routekeeper.sh $(1)/sbin/
endef

$(eval $(call BuildPackage,multiwan))


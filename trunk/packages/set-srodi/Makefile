#
# Copyright (C) 2009 Djarvur.net
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=set-srodi
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/set-srodi
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=Set Static Routes On Dynamic Interfaces
endef


define Build/Configure
	# No configure required
endef

define Build/Compile
	# No compile required
endef

define Package/set-srodi/install
	$(INSTALL_DIR) $(1)/etc/ppp/ip-up.d/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface/
	$(INSTALL_BIN) ./files/etc/udhcpc.user               $(1)/etc/
	$(INSTALL_BIN) ./files/etc/ppp/ip-up.d/set-srodi     $(1)/etc/ppp/ip-up.d/
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/set-srodi $(1)/etc/hotplug.d/iface/
	$(INSTALL_BIN) ./files/sbin/multiwan-routing.sh      $(1)/sbin/
endef

$(eval $(call BuildPackage,set-srodi))


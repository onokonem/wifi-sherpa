#
# Copyright (C) 2009 Djarvur.net
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=multiwan
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/multiwan
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

define Package/multiwan/install
	$(INSTALL_DIR)  $(1)/etc/hotplug.d/firewall/
	$(INSTALL_BIN)  ./files/etc/hotplug.d/firewall/50-multiwan $(1)/etc/hotplug.d/firewall/
	$(INSTALL_DATA) ./files/etc/hotplug.d/firewall/50-miniupnpd.patch $(1)/etc/hotplug.d/firewall/
	$(INSTALL_BIN)  ./files/sbin/multiwan-routing.sh $(1)/sbin/
endef

define Package/multiwan/postinst
#!/bin/sh

if test -z "$${IPKG_INSTROOT}"
  then
  echo "This package is for image-generation-time install ONLY"
  exit 1
  fi

cd "$${IPKG_INSTROOT}/etc/hotplug.d/firewall" &&
patch < 50-miniupnpd.patch &&
rm 50-miniupnpd.patch
endef

$(eval $(call BuildPackage,multiwan))


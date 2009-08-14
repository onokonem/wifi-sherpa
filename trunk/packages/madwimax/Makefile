#
# Copyright (C) 2009 OpenWrt.orgv
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=madwimax
PKG_VERSION:=0.1.1
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://madwimax.googlecode.com/files/
PKG_MD5SUM:=4ebd2d74e887e6f9d6f23067a4ad8272

#PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/madwimax
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=An userspace driver for devices based on Samsung CMC-730 chip
  URL:=http://code.google.com/p/madwimax/
  DEPENDS:+=libusb1 kmod-tun libpthread
endef


define Build/Configure
	$(call Build/Configure/Default, --without-man-pages)
endef

define Build/Compile
	$(call Build/Compile/Default)
endef

define Package/madwimax/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/madwimax $(1)/usr/sbin

	$(INSTALL_DIR)  $(1)/etc/hotplug.d/usb/
	$(INSTALL_BIN)  ./files/etc/hotplug.d/usb/20-madwimax $(1)/etc/hotplug.d/usb/

	$(INSTALL_DIR)  $(1)/etc/init.d/
	$(INSTALL_BIN)  ./files/etc/init.d/madwimax $(1)/etc/init.d/

	$(INSTALL_DIR)  $(1)/etc/madwimax/
	$(INSTALL_BIN)  ./files/etc/madwimax/event.sh $(1)/etc/madwimax/
endef

$(eval $(call BuildPackage,madwimax))


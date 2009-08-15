#
# Copyright (C) 2009 OpenWrt.orgv
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=usbboot-ohci
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=http://usbboot-ohci.googlecode.com/files/
#PKG_MD5SUM:=4ebd2d74e887e6f9d6f23067a4ad8272

#PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/usbboot-ohci
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=Set of scripts to boot router from ext2 flash
  #URL:=no-internet-page-yet
  DEPENDS:=+libext2fs +fs-ext2 +usb-ohci +usb-storage +fdisk
endef


define Build/Configure
	# No configure required
endef

define Build/Compile
	# No compile required
endef

define Package/usbboot-ohci/install
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/etc/init.d/pivotroot   $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/etc/init.d/rcS-usbboot $(1)/etc/init.d/
endef

define Package/usbboot-ohci/postinst
#!/bin/sh

if test -z "$${IPKG_INSTROOT}"
  then
  echo "This package is for image-generation-time install ONLY"
  exit 1
  fi

cd "$${IPKG_INSTROOT}/etc/init.d" &&
patch < rcS-usbboot &&
rm rcS-usbboot
endef

$(eval $(call BuildPackage,usbboot-ohci))


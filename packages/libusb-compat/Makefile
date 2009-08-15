#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libusb-compat
PKG_VERSION:=0.1.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/libusb
PKG_MD5SUM:=570ac2ea085b80d1f74ddc7c6a93c0eb
PKG_FIXUP:=lib

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/libusb-compat
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=A compatibility library for libusb (v 1.0 -> v 0.1)
  URL:=http://libusb.sourceforge.net/
  DEPENDS:=+libusb1
endef

define Build/Configure
	$(call Build/Configure/Default, \
		--enable-shared \
		--enable-static \
	)
endef

TARGET_CFLAGS += $(FPIC)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/libusb-config \
		$(1)/usr/bin/

	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libusb*.{la,so*,a} \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/include/
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/include/usb.h \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libusb.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/libusb-compat/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libusb*.so* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,libusb-compat))

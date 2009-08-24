#
# Copyright (C) 2009 OpenWrt.orgv
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=authorized_keys
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=http://authorized_keys.googlecode.com/files/
#PKG_MD5SUM:=4ebd2d74e887e6f9d6f23067a4ad8272

#PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/authorized_keys
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=Just put some public keys to root authorized_keys
endef


define Build/Configure
	# No configure required
endef

define Build/Compile
	# No compile required
endef

define Package/authorized_keys/install
	$(INSTALL_DIR)  $(1)/root/.ssh/
	$(INSTALL_CONF) ./files/root/.ssh/authorized_keys   $(1)/root/.ssh/
endef

$(eval $(call BuildPackage,authorized_keys))


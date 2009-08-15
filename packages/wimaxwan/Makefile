#
# Copyright (C) 2009 OpenWrt.orgv
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wimaxwan
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/wimaxwan
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=Set of scripts to use WiMax interface as WAN
  DEPENDS:=+madwimax
endef


define Build/Configure
	# Nothing to be done
endef

define Build/Compile
	# Nothing to be done
endef

define Package/wimaxwan/install
	$(INSTALL_DIR)  $(1)/etc/init.d/
	$(INSTALL_BIN)  ./files/etc/init.d/wimaxwan $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,wimaxwan))


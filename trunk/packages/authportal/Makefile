#
# Copyright (C) 2009 OpenWrt.orgv
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=authportal
PKG_VERSION:=0.0.1
PKG_RELEASE:=5

include $(INCLUDE_DIR)/package.mk

define Package/authportal
  SECTION:=fwwrt
  CATEGORY:=FWWRT
  TITLE:=FWWRT xavante-based authentication portal
  DEPENDS:=+xavante-ssl +uci +luasql +luafilesystem
endef


define Build/Configure
    mkdir -p $(PKG_BUILD_DIR)/files/etc/certs/
	$(CP) ./files/etc/certs/CA/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	openssl genrsa -out $(PKG_BUILD_DIR)/ca.key 1024
	openssl req -new -x509 -days 1825 -config $(PKG_BUILD_DIR)/ca.cnf -key $(PKG_BUILD_DIR)/ca.key -out $(PKG_BUILD_DIR)/ca.crt
	openssl genrsa -out $(PKG_BUILD_DIR)/hot.spot.key 1024
	openssl req -new -config $(PKG_BUILD_DIR)/hot.spot.cnf -key $(PKG_BUILD_DIR)/hot.spot.key -out $(PKG_BUILD_DIR)/hot.spot.csr
	openssl x509 -req -in $(PKG_BUILD_DIR)/hot.spot.csr -out $(PKG_BUILD_DIR)/hot.spot.crt -CA $(PKG_BUILD_DIR)/ca.crt -CAkey $(PKG_BUILD_DIR)/ca.key -CAcreateserial -days 3650
	cat $(PKG_BUILD_DIR)/hot.spot.crt $(PKG_BUILD_DIR)/hot.spot.key > $(PKG_BUILD_DIR)/hot.spot.pem
endef

define Package/authportal/install
	$(INSTALL_DIR)  $(1)/usr/lib/lua/fwwrt/
	$(CP) ./files/usr/lib/lua/fwwrt/* $(1)/usr/lib/lua/fwwrt/

	$(INSTALL_DIR)  $(1)/sbin/
	$(INSTALL_BIN)  ./files/sbin/authportal-httpd.lua   $(1)/sbin/

	$(INSTALL_DIR)  $(1)/etc/certs/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/hot.spot.pem $(1)/etc/certs/
	$(INSTALL_DATA) ./files/etc/firewall.fwwrt     $(1)/etc/
	$(INSTALL_DIR)  $(1)/etc/init.d/
	$(INSTALL_BIN)  ./files/etc/init.d/authportal $(1)/etc/init.d/

	$(INSTALL_DIR)  $(1)/www/
	$(CP) ./files/www/* $(1)/www/

	$(INSTALL_DIR)  $(1)/usr/local/fwwrt/
	$(INSTALL_DATA) ./files/usr/local/fwwrt/authportal.sqlite2     $(1)/usr/local/fwwrt/
	

endef

$(eval $(call BuildPackage,authportal))

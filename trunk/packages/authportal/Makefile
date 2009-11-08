#
# Copyright (C) 2009 Djarvur.net, www.djarvur.net, admin@djarvur.net
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
  DEPENDS:=+xavante-ssl +fwwrt-uci-config +luasql +luafilesystem +wsapi +lsyslog +luamd5 +iptables
endef


define Build/Configure
	# Nothing to be done
endef

define Build/Compile
	# Nothing to be done
endef

define Package/authportal/install
	$(INSTALL_DIR)  $(1)/usr/lib/lua/fwwrt/
	$(CP) ./files/usr/lib/lua/fwwrt/* $(1)/usr/lib/lua/fwwrt/

	$(INSTALL_DIR)  $(1)/sbin/
	$(INSTALL_BIN)  ./files/sbin/authportal-httpd.lua   $(1)/sbin/

	$(INSTALL_DIR)  $(1)/etc/certs/
	$(INSTALL_DATA) ./files/etc/certs/hotspot.djarvur.net.crt               $(1)/etc/certs/
	$(INSTALL_DATA) ./files/etc/certs/startssl.com.sub.class1.server.ca.pem $(1)/etc/certs/

	$(INSTALL_DIR)  $(1)/etc/init.d/
	$(INSTALL_BIN)  ./files/etc/init.d/authportal $(1)/etc/init.d/

	$(INSTALL_DATA) ./files/etc/firewall.fwwrt     $(1)/etc/

	$(INSTALL_DIR)  $(1)/www/
	$(CP) ./files/www/* $(1)/www/

	$(INSTALL_DIR)  $(1)/usr/local/fwwrt/
	$(INSTALL_DATA) ./files/usr/local/fwwrt/authportal.sqlite2     $(1)/usr/local/fwwrt/
endef

$(eval $(call BuildPackage,authportal))

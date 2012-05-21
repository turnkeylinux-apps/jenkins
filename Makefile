COMMON_OVERLAYS = tomcat tomcat-apache
COMMON_CONF = postfix-local tomcat apache-vhost

include $(FAB_PATH)/common/mk/turnkey.mk

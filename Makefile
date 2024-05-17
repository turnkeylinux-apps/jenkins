WEBMIN_FW_TCP_INCOMING = 22 80 443 12321

COMMON_OVERLAYS = apache
COMMON_CONF = apache-vhost

include $(FAB_PATH)/common/mk/turnkey.mk

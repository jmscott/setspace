
#
#  Variable DASH_DNS_SUFFIX determines the directory name for the the
#  web server, which matches the DNS name in the ssl certificate.  The
#  default is .com for building dash.setspace.com.  However, typically
#  in development the dns name will be local, like
#
#	dash.setspace.jmscott.cassimac.lan
#	dash.setspace.jmscott.tmonk.local
#
#  using a snake oil, self-signed ssl certificate built for development.
#
ifndef DASH_DNS_VHOST_SUFFIX
$(error DASH_DNS_VHOST_SUFFIX is not set)
endif
#
#  Note:
#	Rarely override:  for example, pgtalk.setspace.com
#
DASH_DNS_VHOST_PREFIX?=dash.setspace

DASH_DNS_VHOST=$(DASH_DNS_VHOST_PREFIX).$(DASH_DNS_VHOST_SUFFIX)

WWW_PREFIX=$(SETSPACE_PREFIX)/www/vhost/$(DASH_DNS_VHOST)

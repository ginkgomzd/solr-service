
this-dir := $(dir $(lastword $(MAKEFILE_LIST)))

# set env vars if not already set
export SOLR_HOST ?= localhost
export SOLR_PORT ?= 8983
export SOLR_BIN ?= /opt/solr/bin

APACHE_MIRROR ?= apache.mesi.com.ar
SOLR_RELEASE ?= 7.3.0
# not used:
ZK_RELEASE ?= 3.4.10

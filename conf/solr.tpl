
export SOLR_HOST ?= {{SOLR_HOST}}
export SOLR_PORT ?= {{SOLR_PORT}}
export SOLR_BIN ?= {{SOLR_BIN}}# path to binary

export APACHE_MIRROR ?= {{APACHE_MIRROR}}# Get a recommended mirror at: http://lucene.apache.org/solr/mirrors-solr-latest-redir.html
export SOLR_RELEASE ?= {{SOLR_RELEASE}}# Release version to download.

export ZK_RELEASE ?= {{ZK_RELEASE}}# zookeeper release to download

export SOLR_TAR = {{SOLR_TAR}}# download file-name
export ZK_TAR = {{ZK_TAR}}# zookeeper download file-name 

export SOLR_DISTRO_URL = {{SOLR_DISTRO_URL}}
export ZK_DISTRO_URL = {{ZK_DISTRO_URL}}

PATCH_FOR_CLOUD ?= # blank for false

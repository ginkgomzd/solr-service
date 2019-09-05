
CONFIG_INCLUDES := conf/solr.conf conf/db.conf
include mk-utils/configure-utils.mk
include mk-utils/help.mk

zk-cmd := $(SOLR_BIN)/solr zk -z $(SOLR_HOST):9983

ping-solr-collections-cmd = curl http://$(SOLR_HOST):$(SOLR_PORT)/api/collections --fail 2>/dev/null 1>/dev/null
ping-solr-cmd = curl http://${SOLR_HOST}:${SOLR_PORT}/api/cores
ping-solr = $(ping-solr-cmd) || false


default: help

install:
	$(MAKE) -f install.mk install

uninstall:
	$(MAKE) -f install.mk uninstall

ping:
	$(ping-solr)

start:
	sudo service solr start

stop:
	sudo service solr stop

list-collections: ping
	@$(zk-cmd) ls /collections

list-cores: ping
	@${zk-cmd} ls /cores

%.xml:
	cp ${*}.tpl ${@}
	$(REPLACE_TOKENS) ${@}

##
# $(eval export DB_DATA_CONFIG_SCHEMA = $(shell cat $${CONFIGSET_TEMPLATE}conf/db-data-config-schema.xml))
# ...using make $(eval ...) does not work because the string is parsed by make, requiring additional escaping.
# instead, we must source the included file within the same shell process as the sub-make.
#
deploy-configset: CONFIGSET_TEMPLATE := configsets/template/
deploy-configset: 
	-rm ${CONFIGSET_TEMPLATE}conf/db-data-config.xml
	DB_DATA_CONFIG_SCHEMA=$$(cat ${CONFIGSET_TEMPLATE}conf/db-data-config-schema.xml); \
	export DB_DATA_CONFIG_SCHEMA; \
	$(MAKE) ${CONFIGSET_TEMPLATE}conf/db-data-config.xml
	# // TODO: this sucks
	sudo rsync -r configsets/ /var/solr/data/configsets/
	sudo chown -R solr:solr /var/solr/data/configsets

solr-status:
	/opt/solr/bin/solr status

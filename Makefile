
CONFIG_INCLUDES := conf/solr.conf conf/db.conf
include utils/configure-utils.mk

zk-cmd := $(SOLR_BIN)/solr zk -z $(SOLR_HOST):9983

ping-solr-collections-cmd = curl http://$(SOLR_HOST):$(SOLR_PORT)/api/collections --fail 2>/dev/null 1>/dev/null
ping-solr-cmd = curl http://${SOLR_HOST}:${SOLR_PORT}/api/cores
ping-solr = $(ping-solr-cmd) || false

define HELP_TEXT
 - Wraps some Solr Service control commands -
 Configure varibales in default.env file.

 Install target invokes install.mk for lazy people.

TODO// ;-)
endef

include utils/help.mk

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

deploy-configset: CONFIGSET_TEMPLATE := configsets/template/
deploy-configset: 
	$(eval export DB_DATA_CONFIG_SCHEMA = $(shell cat ${CONFIGSET_TEMPLATE}conf/db-data-config-schema.xml))
	rm ${CONFIGSET_TEMPLATE}conf/db-data-config.xml
	$(MAKE) ${CONFIGSET_TEMPLATE}conf/db-data-config.xml
	# // TODO: this sucks
	sudo rsync -r configsets/ /var/solr/data/configsets/
	sudo chown -R solr:solr /var/solr/data/configsets

solr-tick:
	cd ${WEB_ROOT} && php wp-content/plugins/msa-capitol-monitor/daemon/rebuild-indexes.php

solr-cores:
	cd ${WEB_ROOT} && php wp-content/plugins/msa-capitol-monitor/daemon/create-cores.php

solr-status:
	/opt/solr/bin/solr status

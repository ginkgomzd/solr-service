
include mdo-config.mk
include mdo-help.mk

zk-cmd := $(SOLR_BIN)/solr zk -z $(SOLR_HOST):9983

ping-solr-collections-cmd = curl http://$(SOLR_HOST):$(SOLR_PORT)/api/collections --fail 2>/dev/null 1>/dev/null
ping-solr-cmd = curl http://${SOLR_HOST}:${SOLR_PORT}/api/cores
ping-solr = $(ping-solr-cmd) || false


default: ping

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

deploy-configset: export DB_DATA_CONFIG_SCHEMA := $(shell cat configsets/template/conf/db-data-config-schema.xml)
deploy-configset: 
	$(REPLACE_TOKENS) < configsets/template/conf/db-data-config.tpl > configsets/template/conf/db-data-config.xml
	# // TODO: this sucks
	sudo rsync -r configsets/ /var/solr/data/configsets/
	sudo chown -R solr:solr /var/solr/data/configsets

solr-status:
	/opt/solr/bin/solr status

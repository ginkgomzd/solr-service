
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

%.xml:
	cp ${*}.tpl ${@}
	$(REPLACE_TOKENS) -i ${@}

##
# $(eval export DB_DATA_CONFIG_SCHEMA = $(shell cat $${CONFIGSET_TEMPLATE}conf/db-data-config-schema.xml))
# ...using make $(eval ...) does not work because the string is parsed by make, requiring additional escaping.
# instead, we must source the included file within the same shell process as the sub-make.
#

create-configset: CONFIGSET_TEMPLATE := src/conf/template/
create-configset: CONFIGSET_DIST := dist/
create-configset:
# Clear dist folder
	sudo rm -r ${CONFIGSET_DIST}
	mkdir ${CONFIGSET_DIST}
	mkdir ${CONFIGSET_DIST}capmon
	mkdir ${CONFIGSET_DIST}capmon/conf

# Make Data Config
	DB_DATA_CONFIG_SCHEMA=$$(cat ${CONFIGSET_TEMPLATE}db-data-config-schema.xml); \
	export DB_DATA_CONFIG_SCHEMA; \
	$(MAKE) ${CONFIGSET_TEMPLATE}db-data-config.xml

# 	// TODO: this sucks
	sudo rsync -r src/conf/static/ dist/capmon/conf
	sudo rsync -r --exclude 'conf' src/ dist
	sudo cp src/conf/template/db-data-config.xml dist/capmon/conf/
# 	sudo chown -R solr:solr /var/solr/data/configsets

solr-status:
	/opt/solr/bin/solr status


include mdo-config.mk
include mdo-help.mk

arch:
	mkdir arch

define download-arch
$(eval CURL_URL = $(if $(findstr zookeeper, ${@}), ${ZK_DISTRO_URL}, ${SOLR_DISTRO_URL} ) )
curl ${CURL_URL} > ${@}
endef

${SOLR_TAR} ${ZK_TAR}: | arch
	$(download-arch)

downloads: ${SOLR_TAR} ${ZK_TAR}

.PHONY: install_solr_service.sh
install_solr_service.sh: downloads
	-rm ${@}
	tar xzf ${SOLR_TAR} solr-$(SOLR_RELEASE)/bin/install_solr_service.sh --strip-components=2

define patch-for-cloud
sudo patch <init.d.solr.patch /etc/init.d/solr
# requires reload
endef

install: downloads install_solr_service.sh | install-libmysql-java 
	# Install solr service, but don't start (-n)
	sudo bash ./install_solr_service.sh ${SOLR_TAR} -n -i /opt -d /var/solr -u solr -s solr -p ${SOLR_PORT}
	$(if ${PATCH_FOR_CLOUD}, $(patch-for-cloud))

enable-cors: 
	sudo cp solr-webapp/webapp/WEB-INF/web.xml $(SOLR_BIN)/../server/solr-webapp/webapp/WEB-INF/web.xml && \
	sudo service solr restart

.PHONY: install-libmysql-java
install-libmysql-java:
	dpkg -S libmysql-java || sudo apt install libmysql-java

stop-solr:
	- sudo service solr stop;

remove-rc.d: stop-solr
	sudo update-rc.d -f solr remove

uninstall: stop-solr remove-rc.d
	- sudo rm -rf /var/solr \
		/opt/solr \
		/opt/solr-$(SOLR_RELEASE) \
		/etc/init.d/solr \
		/etc/default/solr.in.sh && \
		sudo deluser --remove-home solr

clean-downloads:
	-rm -f ${ZK_TAR}
	-rm -f ${SOLR_TAR}

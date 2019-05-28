
CONFIG_INCLUDES := conf/solr.conf
include utils/configure-utils.mk

define HELP_TEXT

- INSTALL SOLR -
	This will download and install Solr.
	As of right now, it does not configure for a production environment: merely a development or stage install.

	Set env vars in env-defaults.env

- PRINCIPAL TARGETS
	- install
	- uninstall
	- downloads

- CLOUD MODE - 
	Set PATCH_FOR_CLOUD=true to install in cloud-mode.

- ENSEMBLE SETUP -
	Ensemble-ready (that's a thing, I think?). Installs "stand-alone" zookeeper for ensemble management.
	Not used for a typical install.

endef

include utils/help.mk

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

install: downloads install-libmysql-java install_solr_service.sh
	# Install solr service, but don't start (-n)
	sudo bash ./install_solr_service.sh ${SOLR_TAR} -n -i /opt -d /var/solr -u solr -s solr -p 8983
	$(if ${PATCH_FOR_CLOUD}, $(patch-for-cloud))

enable-cors: 
	sudo cp solr-webapp/webapp/WEB-INF/web.xml $(SOLR_BIN)/../server/solr-webapp/webapp/WEB-INF/web.xml && \
	sudo service solr restart

.PHONY: install-libmysql-java
install-libmysql-java:
	dpkg -S libmysql-javas || sudo apt install libmysql-java

uninstall:
	@sudo service solr stop && \
	sudo rm -rf /var/solr \
		/opt/solr \
		/opt/solr-$(SOLR_RELEASE) \
		/etc/init.d/solr \
		/etc/default/solr.in.sh && \
	sudo update-rc.d -f solr remove && \
	sudo deluser --remove-home solr

clean-downloads:
	-rm -f ${ZK_TAR}
	-rm -f ${SOLR_TAR}

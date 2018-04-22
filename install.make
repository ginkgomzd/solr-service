
arch:
	@[ -d arch ] || mkdir arch

# zookeeper:
# thought we needed this, but stand-alone zookeeper only needed when setting up an "ensemble"
dl-zk arch/zookeeper-$(ZK_RELEASE).tar.gz: | arch
	curl http://mirrors.ibiblio.org/apache/zookeeper/stable/zookeeper-$(ZK_RELEASE).tar.gz > arch/zookeeper-$(ZK_RELEASE).tar.gz
## END zookeeper

.PHONY: dl-solr
dl-solr: arch/solr-$(SOLR_RELEASE).tgz
arch/solr-$(SOLR_RELEASE).tgz: | $(this)arch
	curl http://$(APACHE_MIRROR)/lucene/solr/$(SOLR_RELEASE)/solr-$(SOLR_RELEASE).tgz > arch/solr-$(SOLR_RELEASE).tgz

install_solr_service.sh: arch/solr-$(SOLR_RELEASE).tgz
	tar xzf arch/solr-$(SOLR_RELEASE).tgz solr-$(SOLR_RELEASE)/bin/install_solr_service.sh --strip-components=2

###
# Install solr service, but don't start (-n)
# as of this writing, default options supplied just to document here
.PHONY: install-solr
install-solr: install_solr_service.sh
	sudo bash ./install_solr_service.sh arch/solr-$(SOLR_RELEASE).tgz -n -i /opt -d /var/solr -u solr -s solr -p 8983 && \
	sudo patch <init.d.solr.patch /etc/init.d/solr && sudo systemctl daemon-reload

.PHONY: enable-cors
enable-cors: solr-webapp/webapp/WEB-INF/web.xml
		sudo cp solr-webapp/webapp/WEB-INF/web.xml $(SOLR_BIN)/../server/solr-webapp/webapp/WEB-INF/web.xml && \
		sudo service solr restart

solr-webapp/webapp/WEB-INF/web.xml:

.PHONY: uninstall-solr
uninstall-solr:
	@sudo service solr stop && \
	sudo rm -rf /var/solr \
		/opt/solr \
		/opt/solr-$(SOLR_RELEASE) \
		/etc/init.d/solr \
		/etc/default/solr.in.sh && \
	sudo update-rc.d -f solr remove && \
	sudo deluser --remove-home solr

clean-downloads:
	@rm -f arch/zookeeper-$(ZK_RELEASE).tar.gz
	@rm -f arch/solr-$(SOLR_RELEASE).tar.gz
